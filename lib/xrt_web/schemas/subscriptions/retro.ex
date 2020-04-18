defmodule XrtWeb.Schemas.Subscriptions.Retro do
  @moduledoc """
  Retro related graphql subscriptions.
  """

  use Absinthe.Schema.Notation

  alias XrtWeb.Resolvers.Retros

  object :retro_subscriptions do
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
        topic: &Retros.retro_updated_trigger/1
      )

      resolve(&Retros.retro_updated/3)
    end
  end
end
