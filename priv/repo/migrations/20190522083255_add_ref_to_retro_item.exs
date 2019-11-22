defmodule Xrt.Repo.Migrations.AddRefToRetroItem do
  use Ecto.Migration
  def change do
    alter table("retro_items") do
      add :ref, :string
    end
  end
end
