defmodule XrtWeb.Schema do
  @moduledoc """
  Main module for the graphql schema.
  """

  use Absinthe.Schema

  import_types(XrtWeb.Types.User)
  import_types(XrtWeb.Types.Retro)
  import_types(XrtWeb.Types.Stats)

  import_types(XrtWeb.Schemas.Queries.User)
  import_types(XrtWeb.Schemas.Queries.Retro)
  import_types(XrtWeb.Schemas.Queries.Stats)

  query do
    import_fields(:user_queries)
    import_fields(:retro_queries)
    import_fields(:stats_queries)
  end

  import_types(XrtWeb.Schemas.Mutations.Retro)

  mutation do
    import_fields(:retro_mutations)
  end

  import_types(XrtWeb.Schemas.Subscriptions.Retro)

  subscription do
    import_fields(:retro_subscriptions)
  end
end
