defmodule Xrt.Repo.Migrations.ChangeActionItemToText do
  use Ecto.Migration

  def change do
    alter table("action_items") do
      modify :title, :text, from: :string
    end
  end
end
