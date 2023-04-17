input "limit" {
  width = 2
  title = "limit"
  type = "combo"
  sql = <<EOQ
    with limits(label) as (
      values
        ( '20' ),
        ( '40' ),
        ( '100' ),
        ( '200' ),
        ( '500' ),
        ( '1000' )
    )
    select
      label,
      label::int as value
    from
      limits
  EOQ
}

input "server" {
  width = 2
  type = "select"
  sql = <<EOQ
    with data as (
      select
        server
      from
        p_mastodon_home_timeline
      limit ${local.limit}
    ),
    counts as (
      select
        server,
        count(*)
      from
        data
      group by
        server
    )
    select
      server || ' (' || count || ')' as label,
      server as value
    from
      counts
    order by
      server
    EOQ
}
