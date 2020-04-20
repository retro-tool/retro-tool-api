defmodule Xrt.Retros.ActionItem do
  @moduledoc """
  Acton items added to a retro.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Xrt.Retros.Retro

  @type id :: integer()

  @type t :: %__MODULE__{
          id: id() | nil,
          title: String.t() | nil,
          completed: boolean() | nil,
          retro_id: Retro.id() | nil
        }

  schema "action_items" do
    field :title, :string
    field :completed, :boolean, default: false
    belongs_to :retro, Retro
    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :completed, :retro_id])
    |> validate_required([:title, :retro_id])
    |> assoc_constraint(:retro)
  end
end
