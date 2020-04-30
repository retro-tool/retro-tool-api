defmodule XrtWeb.Schemas.Queries.Stats do
  @moduledoc """
  Statistics related graphql queries.
  """

  use Absinthe.Schema.Notation

  alias XrtWeb.Graphql.Errors
  alias XrtWeb.Resolvers.Stats

  object :stats_queries do
    @desc "Get statistics"
    field :stats, :stats do
      resolve(Errors.handle_errors(&Stats.stats/3))
    end
  end
end
