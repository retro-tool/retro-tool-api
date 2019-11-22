defmodule Xrt.Retros.RetroItem do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  defenum(TypeEnum, :type, [:works, :improve, :other])

  schema "retro_items" do
    field :title, :string
    field :type, TypeEnum
    field :user_uuid, :string
    field :ref, :string
    belongs_to :parent_retro_item, Xrt.Retros.RetroItem
    belongs_to :retro, Xrt.Retros.Retro
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [
      :title,
      :retro_id,
      :type,
      :user_uuid,
      :parent_retro_item_id,
      :ref
    ])
    |> validate_required([:title, :retro_id, :type, :user_uuid, :ref])
    |> assoc_constraint(:retro)
  end
end
