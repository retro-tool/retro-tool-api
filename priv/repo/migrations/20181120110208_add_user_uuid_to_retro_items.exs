defmodule Xrt.Repo.Migrations.AddUserUuidToRetroItems do
  use Ecto.Migration

  def change do
    alter table(:retro_items) do
      add :user_uuid, :string, null: false
    end

    create index(:retro_items, [:user_uuid])
  end
end
