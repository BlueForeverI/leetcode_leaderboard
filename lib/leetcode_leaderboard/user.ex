defmodule LeetcodeLeaderboard.User do
  use Ecto.Schema

  @type t() :: %__MODULE__{}

  schema "users" do
    field(:username, :string)
    field(:first_name, :string)
    field(:last_name, :string)
  end
end
