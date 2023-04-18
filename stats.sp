dashboard "Stats" {

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
        "[Stats](${local.host}/mastodon.dashboard.Stats)",
        "Stats"
      )
    }
  }

  input "search_term" {
    title = "search_term"
    type = "text"
    width = 2
  }

  container {

    table {
      args = [ self.input.search_term.value ] 
      sql = <<EOQ
        select 
          to_char(created_at, 'YYYY-MM-DD') as created_at,
          display_name,
          content,
          instance_qualified_url
        from 
          p_mastodon_home_timeline 
        where 
          content ~ $1
        order by
          created_at desc
      EOQ
      column "content" {
        wrap = "all"
      }

    }

  }

container {

    chart {
      width = 8
      sql = <<EOQ
        with data as(
          select
            created_at,
            created_at - LAG(created_at) OVER (ORDER BY created_at) AS lag_time
          from 
            p_mastodon_home_timeline
          where 
            -- to_char(created_at, 'YYYY-MM-DD') ~ '2023-04-17' -- ( select to_char(now(), 'YYYY-MM-DD') )
            -- to_char(created_at, 'YYYY-MM-DD') ~  (  select to_char(now(), 'YYYY-MM-DD') )
            created_at > now() - interval '1 day'
          order by
            created_at desc
          limit 1000
        )
        select
          created_at,
          extract(epoch from lag_time) as seconds
        from
          data
        order by
          created_at
      EOQ
    }

    table {
      width = 2
      type = "line"
      sql = <<EOQ
        with data as(
          select
            created_at,
            created_at - LAG(created_at) OVER (ORDER BY created_at) AS lag_time
          from 
            p_mastodon_home_timeline
          where 
            created_at > now() - interval '1 day'
            -- to_char(created_at, 'YYYY-MM-DD') ~  '2023-04-17' --  ( select to_char(now(), 'YYYY-MM-DD') )
          order by
            created_at
          limit 300
        )
        select
          max(extract(epoch from lag_time)) as max_lag,
          avg(extract(epoch from lag_time)) as avg_lag
        from 
          data
      EOQ
    }



  }

container {

    chart {
      sql = <<EOQ
        with data as (
          select 
            to_char(created_at, 'MM-DD : HH24') as created_at
          from 
            p_mastodon_home_timeline 
        )
        select
          created_at,
          count(*)
        from
          data
        group by
          created_at
        order by 
          created_at
      EOQ

    }

  }


  container {
      title = "home timeline"

    card {
      width = 2
      title = "home timeline toots"
      sql = "select count(*) from p_mastodon_home_timeline"
    }

    card {
      width = 2
      title = "newest toot"
      sql = "select to_char(max(created_at), 'MM-DD HH24:MI') as created_at  from p_mastodon_home_timeline"
    }

    table {
      width = 8
      sql = "select * from p_mastodon_home_timeline order by created_at desc limit 10"

    }

  }

  container {
    title = "notifications"

    card {
      width = 2
      title = "notifications"
      sql = "select count(*) from p_mastodon_notifications"
    }

    card {
      width = 2
      title = "newest notification"
      sql = "select to_char(max(created_at), 'MM-DD HH24:MI') as created_at  from p_mastodon_notifications"
    }


    table {
      width = 8
      title = "notifications"
      sql = "select * from p_mastodon_notifications order by created_at desc limit 10"

    }

  }


  container {
    title = "lists"

    card {
      width = 2
      title = "notifications"
      sql = "select count(*) from p_mastodon_notifications"
    }

    card {
      width = 2
      title = "newest notification"
      sql = "select to_char(max(created_at), 'MM-DD HH24:MI') as created_at  from p_mastodon_notifications"
    }


    table {
      width = 8
      title = "notifications"
      sql = "select * from p_mastodon_notifications order by created_at desc limit 10"

    }


  }


}



