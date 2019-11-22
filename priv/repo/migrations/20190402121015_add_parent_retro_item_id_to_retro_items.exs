defmodule Xrt.Repo.Migrations.AddParentRetroItemIdToRetroItems do
  use Ecto.Migration

  def change do
    alter table(:retro_items) do
      add :parent_retro_item_id, :integer
    end

    create index(:retro_items, [:parent_retro_item_id])
  end
end
