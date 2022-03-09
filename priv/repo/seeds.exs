# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LeetcodeLeaderboard.Repo.insert!(%LeetcodeLeaderboard.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias LeetcodeLeaderboard.Repo
alias LeetcodeLeaderboard.User
alias LeetcodeLeaderboard.Problem

Repo.insert!(%User{username: "georgiyolovski", first_name: "Georgi", last_name: "Yolovski"})
Repo.insert!(%User{username: "isiderov", first_name: "Ivan", last_name: "Siderov"})
Repo.insert!(%User{username: "vann4oto98", first_name: "Vanyo", last_name: "Ivanov"})
Repo.insert!(%User{username: "Rostech", first_name: "Rostislav", last_name: "Kazarin"})
Repo.insert!(%User{username: "petargeorgiev11", first_name: "Petar", last_name: "Georgiev"})
Repo.insert!(%User{username: "transtrike", first_name: "Viktor", last_name: "Stamov"})

Repo.insert!(%Problem{
  name: "find-common-characters",
  title: "Find Common Characters",
  start_date: ~D[2022-02-21],
  end_date: ~D[2022-02-27]
})

Repo.insert!(%Problem{
  name: "best-time-to-buy-and-sell-stock",
  title: "Best Time to Buy and Sell Stock",
  start_date: ~D[2022-02-28],
  end_date: ~D[2022-03-06]
})

Repo.insert!(%Problem{
  name: "permutation-in-string",
  title: "Permutation in String",
  start_date: ~D[2022-03-07],
  end_date: ~D[2022-03-13]
})
