defmodule Xrt.Repo.Migrations.ChangeRetroItemToText do
  use Ecto.Migration

  def change do
    alter table("retro_items") do
      modify :title, :text, from: :string
    end
  end
end
