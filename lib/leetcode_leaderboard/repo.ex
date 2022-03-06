defmodule LeetcodeLeaderboard.Repo do
  use Ecto.Repo,
    otp_app: :leetcode_leaderboard,
    adapter: Ecto.Adapters.Postgres
end
