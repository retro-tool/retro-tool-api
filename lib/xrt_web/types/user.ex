defmodule XrtWeb.Types.User do
  @moduledoc """
  User related graphql types.
  """

  use Absinthe.Schema.Notation

  object :user do
    field :uuid, :string
  end
end
