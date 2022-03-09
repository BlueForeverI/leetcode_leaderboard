defmodule LeetcodeLeaderboard.Problem do
  use Ecto.Schema

  @type t() :: %__MODULE__{}

  schema "problems" do
    field(:name, :string)
    field(:title, :string)
    field(:start_date, :date)
    field(:end_date, :date)
  end
end
