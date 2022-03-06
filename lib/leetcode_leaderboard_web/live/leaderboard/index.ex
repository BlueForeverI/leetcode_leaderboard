defmodule LeetcodeLeaderboardWeb.Live.Index do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
        </tr>
      </thead>

      <tbody>
        <%= for row <- @rows do %>
          <tr>
            <td><%= row[:id] %></td>
            <td><%= row[:name] %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def mount(_params, %{}, socket) do
    rows = [%{id: 1, name: "John"}, %{id: 2, name: "Peter"}, %{id: 3, name: "Ted"}]
    {:ok, assign(socket, :rows, rows)}
  end
end
