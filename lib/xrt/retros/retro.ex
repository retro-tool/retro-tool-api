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
          previous_retro_id: id() | nil,
          password: String.t() | nil,
          password_hash: binary() | nil
        }

  use Ecto.Schema

  require EctoEnum

  alias Ecto.Changeset

  EctoEnum.defenum(StatusEnum, :status, [:initial, :review, :actions, :final])

  schema "retros" do
    field :slug, :string
    field :status, StatusEnum, default: :initial
    field :password, :string, virtual: true
    field :password_hash, :binary
    belongs_to :previous_retro, Xrt.Retros.Retro
    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> Changeset.cast(params, [:slug, :status, :previous_retro_id, :password, :password_hash])
    |> Changeset.validate_required([:slug])
    |> Changeset.unique_constraint(:slug)
    |> Changeset.validate_length(:slug, min: 8, max: 64)
    |> encrypt_password()
  end

  defp encrypt_password(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp encrypt_password(%Ecto.Changeset{changes: %{password: password}} = changeset)
       when not is_nil(password) do
    encrypted_password = :crypto.hash(:sha256, password <> "SALT")

    Changeset.put_change(changeset, :password_hash, encrypted_password)
  end

  defp encrypt_password(changeset), do: changeset
end
