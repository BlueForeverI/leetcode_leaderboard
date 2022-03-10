defmodule LeetcodeLeaderboardWeb.Live.Index do
  use LeetcodeLeaderboardWeb, :live_view
  alias LeetcodeLeaderboard.Service
  alias LeetcodeLeaderboard.Problem

  @impl true
  def render(assigns) do
    ~H"""
    <div class="leaderboard">
      <h1>Leaderboard</h1>
      <.form let={f} for={@problem} phx_change="update">
        <%= label f, :id, "Problem" %>
        <%= select f, :id, Enum.map(@problems, &({&1.title, &1.id})) %>
      </.form>

      <%= if @loading do %>
        <div>Loading...</div>
      <% end %>

      <!-- <%= form_for :filter, "#", [phx_change: "update"], fn f -> %>
        <%= radio_button f, :all_submissions, false %>
        <%= label f, :all_submissions_false, "Leaderboard" %>

        <%= radio_button f, :all_submissions, true %>
        <%= label f, :all_submissions_true, "All Submissions" %>
      <% end %> -->
      <%= unless @loading do %>
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
    }
  end

  @impl true
  def handle_event("update", %{"problem" => %{"id" => problem_id}}, socket) do
    send(self(), {:change_problem, problem_id})
    {:noreply, assign(socket, :loading, true)}
  end

  def handle_event("update", %{"filter" => %{"all_submissions" => "true"} = filter}, socket) do
    problem_id = socket.assigns.problem.data.id
    rows = Service.all_submissions(problem_id)

    {:noreply, assign(socket, :rows, rows) |> assign(:filter, filter)}
  end

  def handle_event("update", %{"filter" => %{"all_submissions" => "false"} = filter}, socket) do
    problem_id = socket.assigns.problem.data.id
    rows = Service.leaderboard(problem_id)

    {:noreply, assign(socket, :rows, rows) |> assign(:filter, filter)}
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
end
