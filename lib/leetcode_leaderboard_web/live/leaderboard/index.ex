defmodule LeetcodeLeaderboardWeb.Live.Index do
  use Phoenix.LiveView
  alias LeetcodeLeaderboard.Service

  def render(assigns) do
    ~H"""
    <div class="leaderboard">
      <h1>Leaderboard</h1>
      <table>
        <thead>
          <tr>
            <th>User</th>
            <th>Date</th>
            <th>Language</th>
          </tr>
        </thead>

        <tbody>
          <%= for row <- @rows do %>
            <tr>
              <td><%= row[:user] %></td>
              <td><%= Calendar.strftime(row[:date], "%y-%m-%d %H:%M:%S")%></td>
              <td><a href={row[:url]}><%= row[:lang] %></a></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def mount(_params, %{}, socket) do
    rows = Service.leaderboard()
    {:ok, assign(socket, :rows, rows)}
  end
end
