defmodule XrtWeb.Schema.UserTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :uuid, :string
  end
end
