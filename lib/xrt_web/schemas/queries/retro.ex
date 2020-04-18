defmodule XrtWeb.Schemas.Queries.Retro do
  use Absinthe.Schema.Notation

  alias XrtWeb.Graphql.Errors
  alias XrtWeb.Resolvers.Retros

  object :retro_queries do
    @desc "Get one retro"
    field :retro, :retro do
      arg(:slug, :string)
      arg(:previous_retro_id, :integer)

      resolve(Errors.handle_errors(&Retros.find_retro/3))
    end
  end
end
