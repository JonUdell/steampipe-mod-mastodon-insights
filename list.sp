dashboard "List" {

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
        "[List](${local.host}/mastodon.dashboard.List)",
        "List"
      )
    }
  }

  container {

    table {
      width = 4
      query = query.connection
    }

    input "list" {
      type = "select"
      width = 2
      sql = <<EOQ
        select * from public.mastodon_list_input
      EOQ
    }

    table {
      width = 2
      query = query.list_account_follows
    }

  }

  container {

    table {
      query = query.list
      args = [ self.input.list.value ]
      column "toot" {
        wrap = "all"
      }
    }

    table {
      query = query.list_account
      column "people" {
        wrap = "all"
      }
    }

  }

}

