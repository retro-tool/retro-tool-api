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
          password_hash: binary() | nil
        }

  use Ecto.Schema

  require EctoEnum

  alias Ecto.Changeset

  EctoEnum.defenum(StatusEnum, :status, [:initial, :review, :actions, :final])

  schema "retros" do
    field :slug, :string
    field :status, StatusEnum, default: :initial
    field :password_hash, :binary
    belongs_to :previous_retro, Xrt.Retros.Retro
    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> Changeset.cast(params_encrypt_password(params), [
      :slug,
      :status,
      :previous_retro_id,
      :password_hash
    ])
    |> Changeset.validate_required([:slug])
    |> Changeset.unique_constraint(:slug)
    |> Changeset.validate_length(:slug, min: 8, max: 64)
  end

  @spec update_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_changeset(struct, params) do
    Changeset.cast(struct, params_encrypt_password(params), [:password_hash])
  end

  @spec encrypt_password(String.t()) :: binary()
  def encrypt_password(nil) do
    nil
  end

  def encrypt_password(password) do
    :crypto.hash(:sha256, password <> "SALT")
  end

  defp params_encrypt_password(%{password: nil} = params) do
    Map.put(params, :password_hash, nil)
  end

  defp params_encrypt_password(%{password: password} = params) do
    Map.put(params, :password_hash, encrypt_password(password))
  end

  defp params_encrypt_password(changeset),
    do: changeset
end
