mod "mastodon" {
}

locals {
  host             = "https://pipes.turbot.com/org/pipes-testing/workspace/socialcoop/dashboard"
  server           = "social.coop"
  limit            = 400
  timeline_exclude = "press.coop"
  menu             = <<EOT
[Blocked](__HOST__/mastodon.dashboard.Blocked)
•
[BoostsFromServer](__HOST__/mastodon.dashboard.BoostsFromServer)
•
[BoostsFederated](__HOST__/mastodon.dashboard.BoostsFederated)
•
[Direct](__HOST__/mastodon.dashboard.Direct)
•
[Favorites](__HOST__/mastodon.dashboard.Favorites)
•
[Followers](__HOST__/mastodon.dashboard.Followers)
•
[Following](__HOST__/mastodon.dashboard.Following)
•
[Home](__HOST__/mastodon.dashboard.Home)
•
[List](__HOST__/mastodon.dashboard.List)
•
[Local](__HOST__/mastodon.dashboard.Local)
•
[Me](__HOST__/mastodon.dashboard.Me)
•
[Notification](__HOST__/mastodon.dashboard.Notification)
•
[PeopleSearch](__HOST__/mastodon.dashboard.PeopleSearch)
•
[Rate](__HOST__/mastodon.dashboard.Rate)
•
[Remote](__HOST__/mastodon.dashboard.Remote)
•
[Server](__HOST__/mastodon.dashboard.Server)
•
[StatusSearch](__HOST__/mastodon.dashboard.StatusSearch)
•
[TagExplore](__HOST__/mastodon.dashboard.TagExplore)
•
[TagSearch](__HOST__/mastodon.dashboard.TagSearch)  
EOT
}
