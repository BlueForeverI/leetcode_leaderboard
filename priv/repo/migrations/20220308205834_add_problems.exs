defmodule LeetcodeLeaderboard.Repo.Migrations.AddProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :name, :string
      add :title, :string
      add :start_date, :date
      add :end_date, :date
    end
  end
end
