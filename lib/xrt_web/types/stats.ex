defmodule XrtWeb.Types.Stats do
  @moduledoc """
  Statistics related graphql types.
  """

  use Absinthe.Schema.Notation

  object :stats do
    field :retros, non_null(:retro_stats)
  end

  object :retro_stats do
    field :count, non_null(:integer)
  end
end
