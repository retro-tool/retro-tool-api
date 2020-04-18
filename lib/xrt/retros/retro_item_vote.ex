defmodule Xrt.Retros.RetroItemVote do
  @moduledoc """
  Votes on retro items.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "retro_item_votes" do
    field :user_uuid, :string
    belongs_to :retro_item, Xrt.Retros.RetroItem
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:retro_item_id, :user_uuid])
    |> validate_required([:retro_item_id, :user_uuid])
  end
end
