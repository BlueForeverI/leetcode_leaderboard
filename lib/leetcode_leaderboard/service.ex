defmodule LeetcodeLeaderboard.Service do
  @moduledoc """
  A service for retrieving LeetCode successful submissions for a task.
  """

  def leaderboard() do
    users()
    |> Enum.map(fn user -> first_accepted_submission(user, tasks() |> Enum.at(2)) end)
    |> Enum.filter(fn sub -> sub |> Map.has_key?("timestamp") end)
    |> Enum.sort(&sort_by_date/2)
    |> Enum.map(fn sub ->
      %{
        lang: sub["lang"],
        user: sub["user"],
        date: sub["timestamp"]
          |> Integer.parse()
          |> elem(0)
          |> DateTime.from_unix(:second)
          |> elem(1)
      }
    end)
  end

  def first_accepted_submission(username, task) do
    username
    |> submissions()
    |> Enum.filter(fn %{"titleSlug" => task_title, "statusDisplay" => status} = sub -> task_title == task and status == "Accepted" and current_week_submission(sub) end)
    |> Enum.min_by(&(&1["timestamp"]), fn -> %{} end)
    |> Map.merge(%{"user" => username})
  end

  def current_week_submission(submission) do
    week_start = Date.utc_today() |> Date.beginning_of_week() |> Date.add(-1)
    week_end = Date.utc_today() |> Date.end_of_week() |> Date.add(1)

    submission_date = submission["timestamp"]
    |> Integer.parse()
    |> elem(0)
    |> DateTime.from_unix(:second)
    |> elem(1)
    |> DateTime.to_date()

    submission_date |> Date.compare(week_start) == :gt and submission_date |> Date.compare(week_end) == :lt
  end

  def sort_by_date(first, second) do
    first["timestamp"] < second["timestamp"]
  end

  def submissions(username) do
    Neuron.Config.set(url: "https://leetcode.com/graphql")
    {:ok, %{body: %{"data" => %{"recentSubmissionList" => submissions}}}} = Neuron.query("""
      query getRecentSubmissionList($username: String!, $limit: Int) {
        recentSubmissionList(username: $username, limit: $limit) {
          id
          title
          titleSlug
          timestamp
          statusDisplay
          lang
          __typename
        }
      }
      """,
      %{username: username}
    )

    submissions
  end

  defp tasks, do: ["find-common-characters", "best-time-to-buy-and-sell-stock", "permutation-in-string"]

  defp users, do: ["vann4oto98", "isiderov", "georgiyolovski", "Rostech", "petargeorgiev11"]
end
