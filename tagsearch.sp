dashboard "TagSearch" {
  
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
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Notification](${local.host}/mastodon.dashboard.Notification)
🞄
[Rate](${local.host}/mastodon.dashboard.Rate)
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[StatusSearch](${local.host}/mastodon.dashboard.StatusSearch)
🞄
TagSearch
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

    input "search_term" {
      width = 2
      type = "text"
      title = "search hashtags"
    }

  }

  container {
  
    table {
      args = [ self.input.search_term.value ]
      query = query.hashtag_search
      column "categories" {
        wrap = "all"
      }
    }

  }

}  

