-- create table p_mastodon_accounts_by_list as (...)
with data as (
   select 
    l.title as list,
    l.id as list_id,
    a.id,
    a.acct,
    a.username,
    a.display_name
  from
    mastodon_my_list l
  join
    mastodon_list_account a
  on
    l.id = a.list_id
)
insert into p_mastodon_accounts_by_list (
  list,
  id
) 
select
  list,
  id
from
  data
where
  id not in ( select a.id from p_mastodon_accounts_by_list a )    

