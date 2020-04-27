defmodule Xrt.Repo.Migrations.AddPasswordToRetros do
  use Ecto.Migration

  def change do
    alter table("retros") do
      add :password_hash, :binary
    end
  end
end
