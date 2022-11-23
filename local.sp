dashboard "Local" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 5
      value = <<EOT
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
Local
🞄
[Notification](${local.host}/mastodon.dashboard.Notification)
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[Tag](${local.host}/mastodon.dashboard.Tag)
      EOT
    }
  }

  container {
    table {
      width = 2
      sql = "select distinct _ctx ->> 'connection_name' as server from mastodon_weekly_activity"
    }
  }

  container { 

    table {
      title = "local: recent toots"
      query = query.timeline
      args = [ "local" ]
      column "toot" {
        wrap = "all"
      }
    }

  }

}

