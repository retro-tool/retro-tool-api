defmodule Xrt.Repo.Migrations.AddTypeToRetroItems do
  use Ecto.Migration

  def change do
    Xrt.Retros.RetroItem.TypeEnum.create_type()

    alter table(:retro_items) do
      add :type, Xrt.Retros.RetroItem.TypeEnum.type()
    end
  end
end
