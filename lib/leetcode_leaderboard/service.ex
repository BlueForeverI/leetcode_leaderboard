defmodule LeetcodeLeaderboard.Service do
  @moduledoc """
  A service for retrieving LeetCode successful submissions for a task.
  """
  alias LeetcodeLeaderboard.Repo
  alias LeetcodeLeaderboard.Problem
  alias LeetcodeLeaderboard.User
  alias LeetcodeLeaderboard.Api
  import Ecto.Query

  def leaderboard() do
    problems()
    |> List.last()
    |> Map.get(:id)
    |> leaderboard()
  end

  def leaderboard(problem_id) do
    problem = Repo.get(Problem, problem_id)

    users()
    |> Enum.map(fn user -> first_accepted_submission(user, problem) end)
    |> Enum.filter(& &1)
    |> Enum.sort(&sort_by_date/2)
    |> Enum.map(&transform/1)
  end

  def all_submissions() do
    problems()
    |> List.last()
    |> Map.get(:id)
    |> all_submissions()
  end

  def all_submissions(problem_id) do
    problem = Repo.get(Problem, problem_id)

    users()
    |> Enum.map(&Api.user_submissions/1)
    |> Enum.flat_map(& &1)
    |> Enum.filter(fn sub -> submission_for_problem?(sub, problem) end)
    |> Enum.map(&transform/1)
    |> Enum.sort_by(&(&1[:date]), {:desc, Date})
  end

  def problems() do
    from(p in Problem,
      order_by: [asc: p.start_date]
    )
    |> Repo.all()
  end

  defp first_accepted_submission(user, task) do
    user
    |> Api.user_submissions()
    |> Enum.filter(fn %{"statusDisplay" => status} = sub ->
      status == "Accepted" and submission_for_problem?(sub, task)
    end)
    |> first_submission()
  end

  defp first_submission([]), do: nil

  defp first_submission(subs) do
    subs
    |> Enum.min_by(& &1["timestamp"], fn -> %{} end)
  end

  defp submission_for_problem?(submission, %{
         start_date: start_date,
         end_date: end_date,
         name: name
       }) do
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
      submission_date |> Date.compare(after_week_end) == :lt and
      submission["titleSlug"] == name
  end

  defp sort_by_date(first, second) do
    first["timestamp"] < second["timestamp"]
  end

  defp transform(sub) do
    %{
      lang: sub["lang"],
      user: sub["user"],
      date:
        sub["timestamp"]
        |> Integer.parse()
        |> elem(0)
        |> DateTime.from_unix(:second)
        |> elem(1),
      url: "https://leetcode.com/submissions/detail/#{sub["id"]}",
      status: sub["statusDisplay"]
    }
  end

  defp users() do
    from(u in User)
    |> Repo.all()
  end
end
