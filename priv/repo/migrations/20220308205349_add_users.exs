defmodule LeetcodeLeaderboard.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :first_name, :string
      add :last_name, :string
    end
  end
end
