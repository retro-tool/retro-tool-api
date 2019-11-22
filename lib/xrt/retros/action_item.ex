defmodule Xrt.Retros.ActionItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "action_items" do
    field :title, :string
    field :completed, :boolean, default: false
    belongs_to :retro, Xrt.Retros.Retro
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :completed, :retro_id])
    |> validate_required([:title, :retro_id])
    |> assoc_constraint(:retro)
  end
end
