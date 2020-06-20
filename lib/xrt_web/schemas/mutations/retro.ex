defmodule XrtWeb.Schemas.Mutations.Retro do
  @moduledoc """
  Retro related graphql mutations.
  """

  use Absinthe.Schema.Notation

  alias XrtWeb.Graphql.Errors
  alias XrtWeb.Resolvers.Retros

  object :retro_mutations do
    @desc "Update a retro"
    field :update_retro, type: :retro do
      arg(:slug, non_null(:string))
      arg(:password, :string)
      arg(:input, non_null(:update_retro_input))

      resolve(Errors.handle_errors(&Retros.update_retro/3))
    end

    @desc "Create a works type item"
    field :create_works_item, type: :retro_item do
      arg(:retro_slug, non_null(:string))
      arg(:title, non_null(:string))

      resolve(Errors.handle_errors(&Retros.add_works_item/3))
    end

    @desc "Create a improve type item"
    field :create_improve_item, type: :retro_item do
      arg(:retro_slug, non_null(:string))
      arg(:title, non_null(:string))

      resolve(Errors.handle_errors(&Retros.add_improve_item/3))
    end

    @desc "Create a other type item"
    field :create_other_item, type: :retro_item do
      arg(:retro_slug, non_null(:string))
      arg(:title, non_null(:string))

      resolve(Errors.handle_errors(&Retros.add_other_item/3))
    end

    @desc "Create an action item"
    field :create_action_item, type: :action_item do
      arg(:retro_slug, non_null(:string))
      arg(:title, non_null(:string))

      resolve(Errors.handle_errors(&Retros.add_action_item/3))
    end

    @desc "Combine items into one"
    field :combine_items, type: :retro_item do
      arg(:parent_id, non_null(:string))
      arg(:child_id, non_null(:string))

      resolve(Errors.handle_errors(&Retros.combine_items/3))
    end

    @desc "Detach items into separate rows"
    field :detach_item, type: :retro_item do
      arg(:id, non_null(:string))

      resolve(Errors.handle_errors(&Retros.detach_item/3))
    end

    @desc "Remove items"
    field :remove_item, type: :retro_item do
      arg(:id, non_null(:string))

      resolve(Errors.handle_errors(&Retros.remove_item/3))
    end

    @desc "Remove action items"
    field :remove_action_item, type: :action_item do
      arg(:id, non_null(:string))

      resolve(Errors.handle_errors(&Retros.remove_action_item/3))
    end

    @desc "Toggle action item completed status"
    field :toggle_completed, type: :action_item do
      arg(:action_item_id, non_null(:id))

      resolve(Errors.handle_errors(&Retros.toggle_completed/3))
    end

    @desc "Adds a vote to an item"
    field :add_vote, :retro_item_vote do
      arg(:item_id, non_null(:id))

      resolve(Errors.handle_errors(&Retros.add_vote/3))
    end

    @desc "Transitions retro to the next step"
    field :next_step, :retro do
      deprecate("Use step-specific mutations instead")

      arg(:slug, non_null(:string))

      resolve(Errors.handle_errors(&Retros.next_step/3))
    end

    @desc "Transitions retro to the review step"
    field :transition_to_review_step, :retro do
      arg(:slug, non_null(:string))

      resolve(Errors.handle_errors(&Retros.transition_to_review_step/3))
    end

    @desc "Transitions retro to the actions step"
    field :transition_to_actions_step, :retro do
      arg(:slug, non_null(:string))

      resolve(Errors.handle_errors(&Retros.transition_to_actions_step/3))
    end

    @desc "Transitions retro to the final step"
    field :transition_to_final_step, :retro do
      arg(:slug, non_null(:string))

      resolve(Errors.handle_errors(&Retros.transition_to_final_step/3))
    end
  end
end
