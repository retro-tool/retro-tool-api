defmodule Xrt.Repo.Migrations.AddStatusToRetros do
  use Ecto.Migration

  def change do
    Xrt.Retros.Retro.StatusEnum.create_type()

    alter table(:retros) do
      add :status, Xrt.Retros.Retro.StatusEnum.type()
    end
  end
end
