# home timeline

## create table

create table if not exists public.mastodon_home_timeline as select * from mastodon_toot_home limit 1

## grant table

grant all on public.mastodon_home_timeline to public

## update table

with data as (
  select
    account,
    account_url,
    content,
    created_at,
    display_name,
    followers,
    following,
    id,
    in_reply_to_account_id,
    instance_qualified_account_url,
    instance_qualified_reblog_url,
    instance_qualified_url,
    list_id,
    query,
    reblog,
    reblog_content,
    reblog_server,
    reblog_username,
    reblogs_count,
    replies_count,
    server,
    status,
    url,
    username
  from
    mastodon_toot_home
  limit 200
)
insert into public.mastodon_home_timeline (
    account,
    account_url,
    content,
    created_at,
    display_name,
    followers,
    following,
    id,
    in_reply_to_account_id,
    instance_qualified_account_url,
    instance_qualified_reblog_url,
    instance_qualified_url,
    list_id,
    query,
    reblog,
    reblog_content,
    reblog_server,
    reblog_username,
    reblogs_count,
    replies_count,
    server,
    status,
    url,
    username
)
select
  *
from
  data
where
  id not in ( select t.id from public.mastodon_home_timeline t )    


# lists

## function to create a list table

-- pass the name as, e.g., 'public.mastodon_list_academic'
create or replace function public.mastodon_create_list(table_name text) returns void as $$
  declare formatted_sql text;
  begin
    formatted_sql := format('create table if not exists %I (
      id text,
      list text,
      day text,
      person text,
      url text,
      toot text
    );', table_name);
    formatted_sql := replace(formatted_sql, '"', '');
    execute(formatted_sql);
  end;
$$ language plpgsql;


## function to grant a table

create or replace function public.mastodon_grant_table(table_name text) returns void as $$
  declare formatted_sql text;
  begin
    formatted_sql := format('grant all on %I to public', table_name);
    formatted_sql := replace(formatted_sql, '"', '');
    execute(formatted_sql);
  end;
$$ language plpgsql;


## function to update a list table

select * from mastodon_update_list('Academic', 'public.mastodon_list_academic')

-- pass the name as, e.g., 'public.mastodon_list_academic'
create or replace function public.mastodon_update_list(list_name text, table_name text) returns void as $$
  declare formatted_sql text;
  begin
    formatted_sql := format('
    with list_ids as (
      select
        id,
        title as list
      from
        mastodon_my_list
    ),
    data as (
      select
        t.id,
        l.list,
        to_char(t.created_at, ''YYYY-MM-DD'') as day,
        case
          when t.display_name = '''' then t.username
          else t.display_name
        end as person,
        t.instance_qualified_url as url,
        substring(
          t.content
          from
            1 for 200
        ) as toot
      from
        mastodon_toot_list t
        join list_ids l on l.id = t.list_id
      where
        l.list = ''%s''
        and t.reblog is null -- only original posts
        and t.in_reply_to_account_id is null -- only original posts
      limit
        20
    )
    insert into %I (
      id,
      list,
      day,
      person,
      url,
      toot
    )
    select
      *
    from
      data
    where
      id not in ( select t.id from public.mastodon_list_academic t ) 
    ', list_name, table_name);
    formatted_sql := replace(formatted_sql, '"', '');    
    execute formatted_sql;
  end;
$$ language plpgsql;



## function to read a list table

select * from mastodon_read_list('Academic')

create or replace function public.mastodon_read_list(list_name text) returns table (
  day text,
  person text,
  toot text,
  url text
  ) as $$
  declare table_name text := 'public.p_mastodon_list_' || lower(list_name);
  declare formatted_sql text := format('
    select distinct on (day, person)
      day,
      person,
      toot,
      url
    from
      %I
    order by
      day desc, person
  ', table_name);
  begin
    formatted_sql := replace(formatted_sql, '"', '');
    return query execute formatted_sql;
  end;
$$ language plpgsql;

## function to update a list

create or replace function public.mastodon_update_list(list_name text, table_name text) returns void as $$
 declare formatted_sql text;
 begin
   formatted_sql := format('
   with list_ids as (
     select
       id,
       title as list
     from
       mastodon_my_list
   ),
   data as (
     select
       t.id,
       l.list,
       to_char(t.created_at, ''YYYY-MM-DD'') as day,
       case
         when t.display_name = '''' then t.username
         else t.display_name
       end as person,
       t.instance_qualified_url as url,
       substring(
         t.content
         from
           1 for 200
       ) as toot
     from
       mastodon_toot_list t
       join list_ids l on l.id = t.list_id
     where
       l.list = ''%s''
       and t.reblog is null -- only original posts
       and t.in_reply_to_account_id is null -- only original posts
     limit
       40
   )
   insert into %I (
     id,
     list,
     day,
     person,
     url,
     toot
   )
   select
     *
   from
     data
   where
     id not in ( select t.id from %I t )
   ', list_name, table_name, table_name);
   formatted_sql := replace(formatted_sql, '"', '');
   execute formatted_sql;
 end;
 $$ language plpgsql;

## query to update all lists

with data as (
  select
    title as list_name,
    'public.mastodon_list_' || lower(title) as table_name
  from
    mastodon_my_list
)
select mastodon_update_list(list_name, table_name)
from
  data

## create list_account table

create table if not exists public.mastodon_accounts_by_list as 
  select 
    l.title,
    a.*
  from
    mastodon_my_list l
  join
    mastodon_list_account a
  on
    l.id = a.list_id

## function to update list_account table

## create list_input table

create table if not exists public.mastodon_list_input as 
  with list_account as (
    select * from public.mastodon_list_account
  ),
  counted as (
    select
      title,
      count(*)
    from
      list_account
    group by
      title
    order by
      title
  )
  select
    title || ' (' || count || ')' as label,
    title as value
  from
    counted
  order by
    title

# notifications

## create a notification table

create table public.mastodon_notifications as 
   select * from mastodon_notification limit 100

## a table of notifications to relationships

create table notification_relationship as 
    with notifications as (
      select
        category,
        instance_qualified_account_url,
        account_id,
        display_name as person,
        to_char(created_at, 'MM-DD HH24:MI') as created_at,
        instance_qualified_status_url,
        status_content
      from
        mastodon_notifications
      limit 100
    )
    select
      n.created_at,
      n.category,
      n.person,
      n.instance_qualified_account_url as account_url,
      case when r.following then '↶ ' else '' end as following,
      case when r.followed_by then '↷ ' else '' end as followed_by,
      substring(n.status_content from 1 for 200) as toot,
      case
        when n.instance_qualified_status_url != '' then n.instance_qualified_status_url
        else n.instance_qualified_account_url
      end as toot_url
    from
      notifications n
    join
      mastodon_relationship r
    on
      r.id = n.account_id
    order by
      n.created_at desc   


## function to grant a list table

see above

## update 

with data as (
  select
    account,
    account_id,
    account_url,
    category,
    created_at,
    display_name,
    id,
    instance_qualified_account_url,
    instance_qualified_status_url,
    status,
    status_content,
    status_url
  from
    mastodon_notification
  limit 100
)
insert into public.mastodon_notifications (
  account,
  account_id,
  account_url,
  category,
  created_at,
  display_name,
  id,
  instance_qualified_account_url,
  instance_qualified_status_url,
  status,
  status_content,
  status_url
)
select
  *
from
  data
where
  id not in ( select t.id from public.mastodon_notifications t )


# following

create table if not exists public.mastodon_following as 
  select * from mastodon_my_following

