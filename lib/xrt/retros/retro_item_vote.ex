defmodule Xrt.Retros.RetroItemVote do
  @moduledoc """
  Votes on retro items.
  """

  alias Xrt.Retros.RetroItem

  @type t :: %__MODULE__{
          user_uuid: String.t() | nil,
          retro_item_id: RetroItem.id() | nil
        }

  use Ecto.Schema
  import Ecto.Changeset

  schema "retro_item_votes" do
    field :user_uuid, :string
    belongs_to :retro_item, RetroItem
    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:retro_item_id, :user_uuid])
    |> validate_required([:retro_item_id, :user_uuid])
  end
end
