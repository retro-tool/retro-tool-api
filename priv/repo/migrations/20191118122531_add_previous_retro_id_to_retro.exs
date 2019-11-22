defmodule Xrt.Repo.Migrations.AddPreviousRetroIdToRetro do
  use Ecto.Migration

  def change do
    alter table("retros") do
      add :previous_retro_id, :integer
    end
  end
end
