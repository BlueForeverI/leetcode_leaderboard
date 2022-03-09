defmodule LeetcodeLeaderboard.Api do
  def user_submissions(user) do
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
    |> Enum.map(fn sub -> sub |> Map.merge(%{"user" => user.username}) end)
  end
end
