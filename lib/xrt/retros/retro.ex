defmodule Xrt.Retros.Retro do
  @moduledoc """
  A retrospective.
  """

  @type id :: integer()
  @type slug :: String.t()
  @type status :: :initial | :review | :actions | :final

  @type t :: %__MODULE__{
          id: id() | nil,
          slug: slug() | nil,
          status: status() | nil,
          previous_retro_id: id() | nil
        }

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  defenum(StatusEnum, :status, [:initial, :review, :actions, :final])

  schema "retros" do
    field :slug, :string
    field :status, StatusEnum, default: :initial
    belongs_to :previous_retro, Xrt.Retros.Retro
    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:slug, :status, :previous_retro_id])
    |> validate_required([:slug])
    |> unique_constraint(:slug)
    |> validate_length(:slug, min: 8, max: 64)
  end
end
