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
insert into p_mastodon_notifications (
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
  id not in ( select t.id from p_mastodon_notifications t )
