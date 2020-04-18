defmodule Xrt.Retros do
  @moduledoc """
  Bounded context for retros.
  """

  alias Xrt.Repo

  alias Xrt.Retros.{
    ActionItem,
    Retro,
    RetroItem,
    RetroItemVote,
    Slug,
    StatusMachine
  }

  import Ecto.Query, only: [from: 2]

  def find_retro(id) when is_integer(id) do
    Retro |> Repo.get(id)
  end

  def find_retro(slug) do
    Repo.get_by(Retro, slug: slug)
  end

  def find_previous_retro(retro) do
    {:ok, (retro |> Repo.preload(:previous_retro)).previous_retro}
  end

  def find_next_retro(retro) do
    next_retro = Repo.get_by(Retro, previous_retro_id: retro.id)
    {:ok, next_retro}
  end

  def find_or_create_by_slug(slug, options \\ [])

  def find_or_create_by_slug(nil, previous_retro_id: previous_retro_id)
      when is_integer(previous_retro_id) do
    previous_retro = find_retro(previous_retro_id)
    previous_slug = previous_retro.slug

    slug =
      if Slug.custom?(previous_slug) do
        Slug.next(previous_slug)
      else
        UUID.uuid4()
      end

    find_or_create_by_slug(slug, previous_retro_id: previous_retro_id)
  end

  def find_or_create_by_slug(slug, options) do
    slug = slug || UUID.uuid4()

    case find_retro(slug) do
      nil -> create(slug, options)
      retro -> {:ok, retro}
    end
  end

  def create(slug, options \\ []) do
    previous_retro_id = options |> Keyword.get(:previous_retro_id)

    %Retro{}
    |> Retro.changeset(%{slug: slug, previous_retro_id: previous_retro_id})
    |> Repo.insert()
  end

  def add_item(retro, item_attrs) do
    attrs =
      item_attrs
      |> Map.put(:retro_id, retro.id)
      |> Map.put(:ref, next_item_ref(retro))

    %RetroItem{}
    |> RetroItem.changeset(attrs)
    |> Repo.insert()
  end

  @starting_ref "00"
  def next_item_ref(nil), do: nil
  def next_item_ref(%Retro{id: nil}), do: nil

  def next_item_ref(retro) do
    last_retro_item_with_ref_for_retro =
      from x in RetroItem,
        where: x.retro_id == ^retro.id and not is_nil(x.ref),
        order_by: [desc: x.id],
        limit: 1

    case Repo.one(last_retro_item_with_ref_for_retro) do
      %RetroItem{ref: last_ref} ->
        case Integer.parse(last_ref) do
          :error ->
            nil

          {int, _} ->
            (int + 1) |> Integer.to_string() |> String.pad_leading(2, "0")
        end

      _ ->
        @starting_ref
    end
  end

  def add_action_item(retro, action_item_attrs) do
    attrs = Map.put(action_item_attrs, :retro_id, retro.id)

    %ActionItem{}
    |> ActionItem.changeset(attrs)
    |> Repo.insert()
  end

  def find_retro_items(%Retro{id: retro_id, status: status}, type)
      when status in [:actions, :final] do
    retro_id
    |> find_items_query(type)
    |> Repo.all()
    |> Enum.sort_by(fn x -> -vote_count(x) end)
  end

  def find_retro_items(%Retro{id: retro_id}, type) do
    retro_id
    |> find_items_query(type)
    |> Repo.all()
  end

  defp find_items_query(retro_id, type) do
    from i in RetroItem,
      where: i.retro_id == ^retro_id and i.type == ^type and is_nil(i.parent_retro_item_id),
      order_by: i.id
  end

  def find_action_items(%{id: retro_id}) do
    query = from i in ActionItem, where: i.retro_id == ^retro_id, order_by: i.id

    Repo.all(query)
  end

  def vote_count(%{id: retro_item_id}) do
    ids = [retro_item_id] ++ similar_ids(retro_item_id)
    query = from v in RetroItemVote, where: v.retro_item_id in ^ids, select: count()
    Repo.one(query)
  end

  defp similar_ids(retro_item_id) do
    query = from i in RetroItem, where: i.parent_retro_item_id == ^retro_item_id, select: i.id
    Repo.all(query)
  end

  def find_similar_items(retro) do
    similar_ids(retro.id) |> find_retro_items_by_id
  end

  def find_retro_items_by_id(ids) do
    query = from i in RetroItem, where: i.id in ^ids
    Repo.all(query)
  end

  def set_parent_id(child_id, parent_id) do
    retro_item = Repo.get(RetroItem, child_id)

    retro_item
    |> RetroItem.changeset(%{parent_retro_item_id: parent_id})
    |> Repo.update()
  end

  def remove_item(id) do
    Repo.get(RetroItem, id) |> Repo.delete()
  end

  def remove_action_item(id) do
    Repo.get(ActionItem, id) |> Repo.delete()
  end

  def add_vote(%{id: retro_item_id}, user_uuid) do
    %RetroItemVote{}
    |> RetroItemVote.changeset(%{retro_item_id: retro_item_id, user_uuid: user_uuid})
    |> Repo.insert()
  end

  def transition_to_next_step(retro) do
    StatusMachine.transition_to_next_step(retro)
  end

  @max_votes 20
  def votes_left_for(%Retro{id: retro_id}, user_uuid) do
    query =
      from v in RetroItemVote,
        join: i in RetroItem,
        where: i.id == v.retro_item_id and i.retro_id == ^retro_id and v.user_uuid == ^user_uuid,
        select: count()

    @max_votes - Repo.one(query)
  end
end
