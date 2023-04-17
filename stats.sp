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

}



