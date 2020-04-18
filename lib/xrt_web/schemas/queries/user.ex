defmodule XrtWeb.Schemas.Queries.User do
  @moduledoc """
  User related graphql queries.
  """

  use Absinthe.Schema.Notation

  alias XrtWeb.Resolvers.Users

  object :user_queries do
    @desc "Get the current user"
    field :current_user, :user do
      arg(:retro_slug, non_null(:string))

      resolve(&Users.current_user/3)
    end
  end
end
