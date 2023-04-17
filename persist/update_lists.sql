with data as (
  select
    title as list_name,
    'public.p_mastodon_list_' || lower(title) as table_name
  from
    mastodon_my_list
)
select
  mastodon_update_list(list_name, table_name)
from
  data
