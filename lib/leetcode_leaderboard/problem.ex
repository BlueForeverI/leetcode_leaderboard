defmodule LeetcodeLeaderboard.Problem do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @fields [
    :name,
    :title,
    :start_date,
    :end_date
  ]

  schema "problems" do
    field(:name, :string)
    field(:title, :string)
    field(:start_date, :date)
    field(:end_date, :date)
  end

  def changeset(problem, attrs) do
    problem
    |> cast(attrs, @fields)
  end
end
