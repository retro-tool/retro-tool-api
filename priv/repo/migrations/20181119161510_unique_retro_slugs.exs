defmodule Xrt.Repo.Migrations.UniqueRetroSlugs do
  use Ecto.Migration

  def change do
    create unique_index(:retros, [:slug])
  end
end
