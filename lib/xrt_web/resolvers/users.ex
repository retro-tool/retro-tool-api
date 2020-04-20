defmodule XrtWeb.Resolvers.Users do
  @moduledoc """
  Resolver functions for fields, queries and mutations related to users.
  """

  alias Xrt.Retros
  alias Xrt.Retros.{Retro, RetroItem, RetroItemVote}

  @typep context :: %{context: %{user_uuid: String.t()}}

  @typep user :: %{
           uuid: String.t(),
           votes_left: integer()
         }

  @spec current_user(any(), %{retro_slug: Retro.slug()}, context()) :: {:ok, user()}
  def current_user(_parent, %{retro_slug: slug}, %{context: %{user_uuid: user_uuid}}) do
    retro = Retros.find_retro(slug)

    {:ok, build_user(user_uuid, retro)}
  end

  @spec current_user_updated_trigger(%{retro_item_id: RetroItem.id(), user_uuid: String.t()}) ::
          String.t()
  def current_user_updated_trigger(%{retro_item_id: retro_item_id, user_uuid: user_uuid}) do
    %RetroItem{retro_id: retro_id} = Xrt.Repo.get(RetroItem, retro_item_id)
    retro = Xrt.Repo.get(Retro, retro_id)

    "#{retro.slug}:#{user_uuid}"
  end

  @spec current_user_updated(RetroItemVote.t(), any(), context()) :: {:ok, user()}
  def current_user_updated(%RetroItemVote{retro_item_id: retro_item_id}, _args, %{
        context: %{user_uuid: user_uuid}
      }) do
    %RetroItem{retro_id: retro_id} = Xrt.Repo.get(RetroItem, retro_item_id)
    retro = Xrt.Repo.get(Retro, retro_id)

    {:ok, build_user(user_uuid, retro)}
  end

  defp build_user(user_uuid, retro) do
    %{
      uuid: user_uuid,
      votes_left: Retros.votes_left_for(retro, user_uuid)
    }
  end
end
