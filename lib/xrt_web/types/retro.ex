defmodule XrtWeb.Types.Retro do
  use Absinthe.Schema.Notation

  object :retro do
    field :id, non_null(:integer)
    field :slug, non_null(:string)
    field :status, non_null(:string)

    field :previous_retro, :retro do
      resolve(&XrtWeb.Resolvers.Retros.find_previous_retro/3)
    end

    field :next_retro, :retro do
      resolve(&XrtWeb.Resolvers.Retros.find_next_retro/3)
    end

    field :works, non_null(list_of(:retro_item)) do
      resolve(fn parent, args, resolution ->
        XrtWeb.Resolvers.Retros.find_retro_items(:works, parent, args, resolution)
      end)
    end

    field :improve, non_null(list_of(:retro_item)) do
      resolve(fn parent, args, resolution ->
        XrtWeb.Resolvers.Retros.find_retro_items(:improve, parent, args, resolution)
      end)
    end

    field :others, non_null(list_of(:retro_item)) do
      resolve(fn parent, args, resolution ->
        XrtWeb.Resolvers.Retros.find_retro_items(:other, parent, args, resolution)
      end)
    end

    field :action_items, non_null(list_of(:action_item)) do
      resolve(&XrtWeb.Resolvers.Retros.find_action_items/3)
    end
  end

  object :retro_item do
    field :id, non_null(:id)

    field :title, :string do
      resolve(&XrtWeb.Resolvers.Retros.authorized_title/3)
    end

    field :type, non_null(:string)
    field :user_uuid, non_null(:string)
    field :ref, non_null(:string)

    field :hidden, non_null(:boolean) do
      resolve(&XrtWeb.Resolvers.Retros.hidden_item?/3)
    end

    field :votes, non_null(:integer) do
      resolve(&XrtWeb.Resolvers.Retros.votes/3)
    end

    field :similar_items, non_null(list_of(:retro_item)) do
      resolve(&XrtWeb.Resolvers.Retros.find_similar_items/3)
    end
  end

  object :retro_item_vote do
    field :id, non_null(:id)
  end

  object :action_item do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :completed, non_null(:boolean)
  end
end
