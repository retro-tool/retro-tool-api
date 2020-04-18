defmodule XrtWeb.Schema do
  use Absinthe.Schema

  import_types(XrtWeb.Types.{
    User,
    Retro
  })

  import_types(XrtWeb.Schemas.Queries.{
    User,
    Retro
  })

  query do
    import_fields(:user_queries)
    import_fields(:retro_queries)
  end

  import_types(XrtWeb.Schemas.Mutations.{
    Retro
  })

  mutation do
    import_fields(:retro_mutations)
  end

  import_types(XrtWeb.Schemas.Subscriptions.{
    Retro
  })

  subscription do
    import_fields(:retro_subscriptions)
  end
end
