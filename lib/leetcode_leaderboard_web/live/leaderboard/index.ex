defmodule LeetcodeLeaderboardWeb.Live.Index do
  use LeetcodeLeaderboardWeb, :live_view
  alias LeetcodeLeaderboard.Service
  alias LeetcodeLeaderboard.Problem

  @impl true
  def render(assigns) do
    ~H"""
    <div class="leaderboard">
      <h1>Leaderboard</h1>
      <div class="board-filters">
        <.form let={f} for={@problem} phx_change="update">
          <%= label f, :id, "Problem" %>
          <%= select f, :id, Enum.map(@problems, &({&1.title, &1.id})) %>
        </.form>

        <div class="buttons-panel">
          <div>
            <button phx-click="update" phx-value-all_submissions="false"
              class={"button-container " <> (not @all_submissions && "active" || "")}>Leaderboard</button>
          </div>
          <div>
            <div>
              <button phx-click="update" phx-value-all_submissions="true"
                class={"button-container " <> (@all_submissions && "active" || "")}>All Submissions</button>
            </div>
          </div>
        </div>
      </div>

      <%= if @loading do %>
        <div>Loading...</div>
      <% end %>

      <%= unless @loading do %>
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Date</th>
              <%= if @all_submissions do %>
                <th>Status</th>
              <% end %>
              <th>Language</th>
              <th>View</th>
            </tr>
          </thead>

          <tbody>
            <%= for row <- @rows do %>
              <tr>
                <td><%= row[:user] %></td>
                <td><%= Calendar.strftime(row[:date], "%y-%m-%d %H:%M:%S")%></td>
                <%= if @all_submissions do %>
                  <td><%= row[:status] %></td>
                <% end %>
                <td><%= row[:lang] %></td>
                <td><a href={row[:url]} target="_blank">View code</a></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, %{}, socket) do
    problems = Service.problems()

    send(self(), {:initial_load})

    {
      :ok,
      socket
      |> assign(:rows, [])
      |> assign(:problems, problems)
      |> assign(:problem, problems |> List.last() |> Problem.changeset(%{}))
      |> assign(:loading, true)
      |> assign(:all_submissions, false)
    }
  end

  @impl true
  def handle_event("update", %{"problem" => %{"id" => problem_id}}, socket) do
    send(self(), {:change_problem, problem_id})
    {:noreply, assign(socket, :loading, true)}
  end

  def handle_event("update", %{"all_submissions" => all_submissions}, socket) do
    send(self(), {:change_mode, all_submissions})
    {:noreply, assign(socket, :loading, true)}
  end

  @impl true
  def handle_info({:initial_load}, socket) do
    rows = Service.leaderboard()

    {
      :noreply,
      socket
      |> assign(:rows, rows)
      |> assign(:loading, false)
    }
  end

  def handle_info({:change_problem, problem_id}, socket) do
    {:noreply,
     socket
     |> assign(:loading, true)
     |> assign(:rows, Service.leaderboard(problem_id))
     |> assign(:loading, false)}
  end

  def handle_info({:change_mode, all_submissions}, socket) do
    problem_id = socket.assigns.problem.data.id

    {
      :noreply,
      socket
      |> assign(:loading, true)
      |> assign(:rows, all_submissions == "true" && Service.all_submissions(problem_id) || Service.leaderboard(problem_id))
      |> assign(:loading, false)
      |> assign(:all_submissions, all_submissions == "true")
    }
  end
end
