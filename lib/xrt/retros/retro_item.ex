defmodule Xrt.Retros.RetroItem do
  @moduledoc """
  Items added to a retro.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  alias Xrt.Retros.Retro

  @type id :: integer()

  @type type :: :works | :improve | :other

  @type t :: %__MODULE__{
          id: id() | nil,
          title: String.t() | nil,
          type: type() | nil,
          user_uuid: String.t() | nil,
          ref: String.t() | nil,
          parent_retro_item_id: id() | nil,
          retro_id: Retro.id() | nil
        }

  defenum(TypeEnum, :type, [:works, :improve, :other])

  schema "retro_items" do
    field :title, :string
    field :type, TypeEnum
    field :user_uuid, :string
    field :ref, :string
    belongs_to :parent_retro_item, __MODULE__
    belongs_to :retro, Retro
    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
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
