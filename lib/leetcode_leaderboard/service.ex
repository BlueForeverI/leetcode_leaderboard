defmodule LeetcodeLeaderboard.Service do
  @moduledoc """
  A service for retrieving LeetCode successful submissions for a task.
  """
  alias LeetcodeLeaderboard.Repo
  alias LeetcodeLeaderboard.Problem
  alias LeetcodeLeaderboard.User
  import Ecto.Query

  def leaderboard() do
    last_problem = problems() |> List.last()

    users()
    |> Enum.map(fn user -> first_accepted_submission(user, last_problem) end)
    |> Enum.filter(fn sub -> sub |> Map.has_key?("timestamp") end)
    |> Enum.sort(&sort_by_date/2)
    |> Enum.map(fn sub ->
      %{
        lang: sub["lang"],
        user: sub["user"],
        date:
          sub["timestamp"]
          |> Integer.parse()
          |> elem(0)
          |> DateTime.from_unix(:second)
          |> elem(1),
        url: "https://leetcode.com/submissions/detail/#{sub["id"]}"
      }
    end)
  end

  def first_accepted_submission(user, task) do
    user
    |> submissions()
    |> Enum.filter(fn %{"titleSlug" => task_title, "statusDisplay" => status} = sub ->
      task_title == task.name and status == "Accepted" and
        submission_between_dates(sub, task.start_date, task.end_date)
    end)
    |> Enum.min_by(& &1["timestamp"], fn -> %{} end)
    |> Map.merge(%{"user" => user.username})
  end

  def submission_between_dates(submission, start_date, end_date) do
    before_week_start = start_date |> Date.add(-1)
    after_week_end = end_date |> Date.add(1)

    submission_date =
      submission["timestamp"]
      |> Integer.parse()
      |> elem(0)
      |> DateTime.from_unix(:second)
      |> elem(1)
      |> DateTime.to_date()

    submission_date |> Date.compare(before_week_start) == :gt and
      submission_date |> Date.compare(after_week_end) == :lt
  end

  def sort_by_date(first, second) do
    first["timestamp"] < second["timestamp"]
  end

  def submissions(user) do
    Neuron.Config.set(url: "https://leetcode.com/graphql")

    {:ok, %{body: %{"data" => %{"recentSubmissionList" => submissions}}}} =
      Neuron.query(
        """
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
        %{username: user.username}
      )

    submissions
  end

  defp problems() do
    from(p in Problem,
      order_by: [asc: p.start_date]
    )
    |> Repo.all()
  end

  defp users() do
    from(u in User)
    |> Repo.all()
  end
end
