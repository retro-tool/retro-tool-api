defmodule Xrt.Repo.Migrations.CreateRetroItemVotes do
  use Ecto.Migration

  def change do
    create table(:retro_item_votes) do
      add :retro_item_id, :integer, null: false
      add :user_uuid, :string, null: false
      timestamps()
    end
  end
end
