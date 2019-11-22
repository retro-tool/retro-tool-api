defmodule XrtWeb.Schema do
  use Absinthe.Schema
  import_types(XrtWeb.Schema.RetroTypes)
  import_types(XrtWeb.Schema.UserTypes)

  alias XrtWeb.Resolvers

  import XrtWeb.Schema.Errors, only: [handle_errors: 1]

  query do
    @desc "Get one retro"
    field :retro, :retro do
      arg(:slug, :string)
      arg(:previous_retro_id, :integer)

      resolve(handle_errors(&Resolvers.Retros.find_retro/3))
    end

    field :current_user, :user do
      arg(:retro_slug, non_null(:string))

      resolve(&Resolvers.Users.current_user/3)
    end
  end

  mutation do
    @desc "Create a works type item"
    field :create_works_item, type: :retro_item do
      arg(:retro_slug, non_null(:string))
      arg(:title, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.add_works_item/3))
    end

    @desc "Create a improve type item"
    field :create_improve_item, type: :retro_item do
      arg(:retro_slug, non_null(:string))
      arg(:title, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.add_improve_item/3))
    end

    @desc "Create a other type item"
    field :create_other_item, type: :retro_item do
      arg(:retro_slug, non_null(:string))
      arg(:title, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.add_other_item/3))
    end

    @desc "Create an action item"
    field :create_action_item, type: :action_item do
      arg(:retro_slug, non_null(:string))
      arg(:title, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.add_action_item/3))
    end

    @desc "Combine items into one"
    field :combine_items, type: :retro_item do
      arg(:parent_id, non_null(:string))
      arg(:child_id, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.combine_items/3))
    end

    @desc "Detach items into separate rows"
    field :detach_item, type: :retro_item do
      arg(:id, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.detach_item/3))
    end

    @desc "Remove items"
    field :remove_item, type: :retro_item do
      arg(:id, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.remove_item/3))
    end

    @desc "Remove action items"
    field :remove_action_item, type: :action_item do
      arg(:id, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.remove_action_item/3))
    end

    @desc "Toggle action item completed status"
    field :toggle_completed, type: :action_item do
      arg(:action_item_id, non_null(:id))

      resolve(handle_errors(&Resolvers.Retros.toggle_completed/3))
    end

    @desc "Adds a vote to an item"
    field :add_vote, :retro_item_vote do
      arg(:item_id, non_null(:id))

      resolve(handle_errors(&Resolvers.Retros.add_vote/3))
    end

    @desc "Transitions retro to the next step"
    field :next_step, :retro do
      arg(:slug, non_null(:string))

      resolve(handle_errors(&Resolvers.Retros.next_step/3))
    end
  end

  subscription do
    field :retro_updated, :retro do
      arg(:slug, non_null(:string))

      config(fn args, _ ->
        {:ok, topic: args.slug}
      end)

      trigger(
        [
          :create_works_item,
          :create_improve_item,
          :create_other_item,
          :create_action_item,
          :add_vote,
          :next_step,
          :toggle_completed,
          :combine_items,
          :detach_item,
          :remove_item,
          :remove_action_item
        ],
        topic: &Resolvers.Retros.retro_updated_trigger/1
      )

      resolve(&Resolvers.Retros.retro_updated/3)
    end
  end
end
