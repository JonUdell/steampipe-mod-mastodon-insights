/*
create table public.p_mastodon_notification_follow as 

with data as (
  select
    account_id
  from
    mastodon_notification
  limit
    1
)
select
  d.account_id,
  r.following,
  r.followed_by
from
  data d
join
  mastodon_relationship r 
on
  d.account_id = r.id
*/

with data as (
  select
    account_id
  from
    mastodon_notification
  limit
    40
)
insert into p_mastodon_notification_follow (
  account_id,
  following,
  followed_by
)
select distinct
  d.account_id,
  r.following,
  r.followed_by
from
  data d
join
  mastodon_relationship r 
on
  d.account_id = r.id
where
  d.account_id not in ( select n.account_id from p_mastodon_notification_follow n )    
