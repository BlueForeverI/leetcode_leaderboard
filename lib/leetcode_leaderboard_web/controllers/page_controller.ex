defmodule LeetcodeLeaderboardWeb.PageController do
  use LeetcodeLeaderboardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
