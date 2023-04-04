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
        "Home"
      )
    }
  }

  container {
      title = "home timeline"

    card {
      width = 2
      title = "home timeline toots"
      sql = "select count(*) from mastodon_home_timeline"
    }

    card {
      width = 2
      title = "newest toot"
      sql = "select to_char(max(created_at), 'MM-DD HH24:MI') as created_at  from mastodon_home_timeline"
    }

    table {
      width = 6
      sql = "select * from mastodon_home_timeline order by created_at desc limit 10"

    }

  }

  container {
    title = "notifications"

    card {
      width = 2
      title = "notifications"
      sql = "select count(*) from mastodon_notifications"
    }

    card {
      width = 2
      title = "newest notification"
      sql = "select to_char(max(created_at), 'MM-DD HH24:MI') as created_at  from mastodon_notifications"
    }


    table {
      width = 6
      title = "notifications"
      sql = "select * from mastodon_notifications order by created_at limit 10"

    }


  }

}



