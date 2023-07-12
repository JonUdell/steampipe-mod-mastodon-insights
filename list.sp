dashboard "List" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = replace(
        replace(
          "${local.menu}",
          "__HOST__",
          "${local.host}"
        ),
        "[List](${local.host}/mastodon.dashboard.List)",
        "List"
      )
    }
  }

  with "toots_for_list_create" {
    sql = <<EOQ
      create or replace function toots_for_list(list_name text) returns table (
        day text,
        person text,
        toot text,
        url text
      ) as $$
      with list_ids as (
        select
          id,
          title as list
        from
        mastodon_social_coop.mastodon_my_list
      ),
      data as (
        select
          l.list,
          to_char(t.created_at, 'YYYY-MM-DD') as day,
          case when t.display_name = '' then t.username else t.display_name end as person,
          t.instance_qualified_url as url,
          substring(t.content from 1 for 200) as toot
        from
          mastodon_social_coop.mastodon_toot_list t
        join
          list_ids l
        on
          l.id = t.list_id
        where
          l.list = list_name
          and t.reblog is null -- only original posts
          and t.in_reply_to_account_id is null -- only original posts
          limit 20
      )
      select distinct on (person, day) -- only one per person per day
        day,
        person,
        toot,
        url
      from
        data
      order by
        day desc, person
      $$ language sql
    EOQ
  }

  with "toots_for_list_view" {
    sql = <<EOQ
      create or replace function toots_for_list_view(list_name text)
      returns table (day text, person text, toot text, url text) as $$
      begin
        return query execute
          format('select distinct on (person, day) -- only one per person per day
                    day,
                    person,
                    toot,
                    url
                  from toots_for_list_%I
                  order by day desc, person', lower(list_name));
      end;
      $$ language plpgsql;    
    EOQ
  }


  with "toots_for_list" {
    sql = <<EOQ
      create or replace function toots_for_list(list_name text) returns table (
        day text,
        person text,
        toot text,
        url text
      ) as $$
      with list_ids as (
        select
          id,
          title as list
        from
        mastodon_social_coop.mastodon_my_list
      ),
      data as (
        select
          l.list,
          to_char(t.created_at, 'YYYY-MM-DD') as day,
          case when t.display_name = '' then t.username else t.display_name end as person,
          t.instance_qualified_url as url,
          substring(t.content from 1 for 200) as toot
        from
          mastodon_social_coop.mastodon_toot_list t
        join
          list_ids l
        on
          l.id = t.list_id
        where
          l.list = list_name
          and t.reblog is null -- only original posts
          and t.in_reply_to_account_id is null -- only original posts
          limit 20
      )
      select distinct on (person, day) -- only one per person per day
        day,
        person,
        toot,
        url
      from
        data
      order by
        day desc, person
      $$ language sql
    EOQ
  }


  container {

    table {
      width = 4
      query = query.connection
    }

    input "list" {
      type = "select"
      width = 2
      sql = <<EOQ
        select
          l.title as label,
          l.title as value
        from
          mastodon_my_list l
        order by
          title
      EOQ
    }

  }

  container {

    table {
      width = 8
      query = query.list
      args = [ self.input.list.value ]
      column "toot" {
        wrap = "all"
      }
    }

    container {
      width = 4

      table {
        width = 6
        query = query.list_account_follows
      }

      table {
        query = query.list_account
        args = [ self.input.list.value ]
        column "people" {
          wrap = "all"
        }
      }

    }


  }

}

