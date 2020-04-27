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

  @spec find_retro(Retro.id() | Retro.slug() | nil) :: Retro.t() | nil
  def find_retro(nil) do
    nil
  end

  @spec find_retro(Retro.id() | Retro.slug()) :: Retro.t() | nil
  def find_retro(id) when is_integer(id) do
    Retro |> Repo.get(id)
  end

  def find_retro(slug) do
    Repo.get_by(Retro, slug: slug)
  end

  @spec find_previous_retro(Retro.t()) :: Retro.t()
  def find_previous_retro(retro) do
    retro |> Repo.preload(:previous_retro) |> Map.get(:previous_retro)
  end

  @spec find_next_retro(Retro.t()) :: Retro.t()
  def find_next_retro(retro) do
    Repo.get_by(Retro, previous_retro_id: retro.id)
  end

  @spec find_or_create_by_slug(Retro.slug() | nil, keyword()) ::
          {:ok, Retro.t()} | {:error, any()}
  def find_or_create_by_slug(slug, options \\ [])

  def find_or_create_by_slug(nil, options) do
    slug =
      options
      |> Keyword.get(:previous_retro_id)
      |> find_retro()
      |> case do
        nil ->
          UUID.uuid4()

        %Retro{slug: previous_slug} ->
          next_slug(previous_slug)
      end

    find_or_create_by_slug(slug, options)
  end

  def find_or_create_by_slug(slug, options) do
    slug = slug || UUID.uuid4()

    case find_retro(slug) do
      nil -> create(slug, options)
      retro -> {:ok, retro}
    end
  end

  defp next_slug(previous_slug) do
    if Slug.custom?(previous_slug) do
      Slug.next(previous_slug)
    else
      UUID.uuid4()
    end
  end

  @spec create(Retro.slug(), keyword()) :: {:ok, Retro.t()} | {:error, any()}
  def create(slug, options \\ []) do
    previous_retro_id = options |> Keyword.get(:previous_retro_id)
    password = options |> Keyword.get(:password)

    %Retro{}
    |> Retro.changeset(%{slug: slug, previous_retro_id: previous_retro_id, password: password})
    |> Repo.insert()
  end

  @spec add_item(Retro.t(), map()) :: {:ok, RetroItem.t()} | {:error, any()}
  def add_item(retro, item_attrs) do
    attrs =
      item_attrs
      |> Map.put(:retro_id, retro.id)
      |> Map.put(:ref, next_item_ref(retro))

    %RetroItem{}
    |> RetroItem.changeset(attrs)
    |> Repo.insert()
  end

  @spec next_item_ref(Retro.t() | nil) :: String.t() | nil
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

  @spec add_action_item(Retro.t(), map()) :: {:ok, ActionItem.t()} | {:error, any()}
  def add_action_item(retro, action_item_attrs) do
    attrs = Map.put(action_item_attrs, :retro_id, retro.id)

    %ActionItem{}
    |> ActionItem.changeset(attrs)
    |> Repo.insert()
  end

  @spec find_retro_items(Retro.t(), RetroItem.type()) :: list(RetroItem.t())
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

  @spec find_action_items(Retro.t()) :: list(ActionItem.t())
  def find_action_items(%{id: retro_id}) do
    query = from i in ActionItem, where: i.retro_id == ^retro_id, order_by: i.id

    Repo.all(query)
  end

  @spec vote_count(RetroItem.t()) :: integer()
  def vote_count(%RetroItem{id: retro_item_id}) do
    ids = [retro_item_id] ++ similar_ids(retro_item_id)
    query = from v in RetroItemVote, where: v.retro_item_id in ^ids, select: count()
    Repo.one(query)
  end

  @spec find_similar_items(RetroItem.t()) :: list(RetroItem.t())
  def find_similar_items(retro_item) do
    similar_ids(retro_item.id) |> find_retro_items_by_id
  end

  defp similar_ids(retro_item_id) do
    query = from i in RetroItem, where: i.parent_retro_item_id == ^retro_item_id, select: i.id
    Repo.all(query)
  end

  defp find_retro_items_by_id(ids) do
    query = from i in RetroItem, where: i.id in ^ids
    Repo.all(query)
  end

  @spec set_parent_id(RetroItem.id(), RetroItem.id() | nil) ::
          {:ok, RetroItem.t()} | {:error, any()}
  def set_parent_id(child_id, parent_id) do
    retro_item = Repo.get(RetroItem, child_id)

    retro_item
    |> RetroItem.changeset(%{parent_retro_item_id: parent_id})
    |> Repo.update()
  end

  @spec remove_item(RetroItem.id()) :: {:ok, RetroItem.t()} | {:error, any()}
  def remove_item(id) do
    Repo.get(RetroItem, id) |> Repo.delete()
  end

  @spec remove_action_item(ActionItem.id()) :: {:ok, ActionItem.t()} | {:error, any()}
  def remove_action_item(id) do
    Repo.get(ActionItem, id) |> Repo.delete()
  end

  @spec add_vote(RetroItem.t() | %{id: RetroItem.t()}, String.t()) ::
          {:ok, RetroItemVote.t()} | {:error, any()}
  def add_vote(retro_item, user_uuid) do
    %RetroItemVote{}
    |> RetroItemVote.changeset(%{retro_item_id: retro_item.id, user_uuid: user_uuid})
    |> Repo.insert()
  end

  @spec transition_to_next_step(Retro.t()) :: {:ok, Retro.t()} | {:error, any()}
  def transition_to_next_step(retro) do
    StatusMachine.transition_to_next_step(retro)
  end

  @spec votes_left_for(Retro.t(), String.t()) :: integer()
  @max_votes 20
  def votes_left_for(%Retro{id: retro_id}, user_uuid) do
    query =
      from v in RetroItemVote,
        join: i in RetroItem,
        where: i.id == v.retro_item_id and i.retro_id == ^retro_id and v.user_uuid == ^user_uuid,
        select: count()

    @max_votes - Repo.one(query)
  end

  @spec count() :: integer()
  def count do
    Repo.aggregate(Retro, :count)
  end
end
