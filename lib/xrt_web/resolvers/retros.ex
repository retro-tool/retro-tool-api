defmodule XrtWeb.Resolvers.Retros do
  @moduledoc """
  Resolver functions for fields, queries and mutations related to retros.
  """

  alias Xrt.Retros

  alias Xrt.Retros.{
    ActionItem,
    Retro,
    RetroItem,
    RetroItemVote
  }

  alias XrtWeb.Graphql.Errors

  @typep context :: %{context: %{user_uuid: String.t()}}

  @spec find_retro(
          any(),
          %{
            required(:slug) => Retro.slug() | nil,
            optional(:previous_retro_id) => Retro.id(),
            optional(:password) => String.t()
          },
          any()
        ) ::
          {:ok, Retro.t()} | {:error, any()}
  def find_retro(_parent, args, _resolution) do
    {password, args} = Map.pop(args, :password, nil)

    args
    |> do_find_retro()
    |> check_password(password)
  end

  @spec update_retro(any(), %{slug: Retro.slug(), input: %{password: String.t()}}, any()) ::
          {:ok, Retro.t()} | {:error, any()}
  def update_retro(_parent, %{input: input} = args, _resolution) do
    {password, args} = Map.pop(args, :password, nil)

    args
    |> do_find_retro()
    |> check_password(password)
    |> case do
      {:ok, %Retro{} = retro} ->
        Retros.update(retro, input)

      result ->
        result
    end
  end

  @spec find_previous_retro(Retro.t(), %{}, any()) :: {:ok, Retro.t() | nil}
  def find_previous_retro(parent, %{}, _resolution) do
    {:ok, Retros.find_previous_retro(parent)}
  end

  @spec find_next_retro(Retro.t(), map(), any()) :: {:ok, Retro.t() | nil}
  def find_next_retro(child, %{}, _resolution) do
    {:ok, Retros.find_next_retro(child)}
  end

  @typep retro_item_creation_args :: %{
           retro_slug: Retro.slug(),
           title: String.t()
         }

  @spec add_works_item(any(), retro_item_creation_args(), context()) ::
          {:ok, RetroItem.t()} | {:error, any()}
  def add_works_item(_parent, args, %{context: context}) do
    args
    |> Map.put(:type, :works)
    |> create_retro_item(context)
  end

  @spec add_improve_item(any(), retro_item_creation_args(), context()) ::
          {:ok, RetroItem.t()} | {:error, any()}
  def add_improve_item(_parent, args, %{context: context}) do
    args
    |> Map.put(:type, :improve)
    |> create_retro_item(context)
  end

  @spec add_other_item(any(), retro_item_creation_args(), context()) ::
          {:ok, RetroItem.t()} | {:error, any()}
  def add_other_item(_parent, args, %{context: context}) do
    args
    |> Map.put(:type, :other)
    |> create_retro_item(context)
  end

  defp create_retro_item(%{retro_slug: slug, title: title, type: type}, %{user_uuid: user_uuid}) do
    case Retros.find_retro(slug) do
      nil ->
        {:error, Errors.error(:not_found, "Retro not found")}

      retro ->
        Retros.add_item(retro, %{title: title, type: type, user_uuid: user_uuid})
    end
  end

  @spec add_action_item(any(), retro_item_creation_args(), context()) ::
          {:ok, ActionItem.t()} | {:error, any()}
  def add_action_item(_parent, %{retro_slug: slug, title: title}, _context) do
    case Retros.find_retro(slug) do
      nil ->
        {:error, Errors.error(:not_found, "Retro not found")}

      retro ->
        Retros.add_action_item(retro, %{title: title})
    end
  end

  @spec combine_items(any(), %{parent_id: RetroItem.id(), child_id: RetroItem.id()}, context()) ::
          {:ok, RetroItem.t()} | {:error, any()}
  def combine_items(_parent, %{parent_id: parent_id, child_id: child_id}, _context) do
    Retros.set_parent_id(child_id, parent_id)
  end

  @spec detach_item(any(), %{id: RetroItem.id()}, context()) ::
          {:ok, RetroItem.t()} | {:error, any()}
  def detach_item(_parent, %{id: id}, _context) do
    Retros.set_parent_id(id, nil)
  end

  @spec remove_item(any(), %{id: RetroItem.id()}, context()) ::
          {:ok, RetroItem.t()} | {:error, any()}
  def remove_item(_parent, %{id: id}, _context) do
    Retros.remove_item(id)
  end

  @spec remove_action_item(any(), %{id: ActionItem.id()}, context()) ::
          {:ok, ActionItem.t()} | {:error, any()}
  def remove_action_item(_parent, %{id: id}, _context) do
    Xrt.Retros.remove_action_item(id)
  end

  @spec find_similar_items(RetroItem.t(), any(), any()) :: {:ok, list(RetroItem.t())}
  def find_similar_items(parent, _args, _resolution) do
    {:ok, Retros.find_similar_items(parent)}
  end

  @spec toggle_completed(any(), %{action_item_id: ActionItem.id()}, any()) ::
          {:ok, ActionItem.t()} | {:error, any()}
  def toggle_completed(_parent, %{action_item_id: action_item_id}, _resolution) do
    action_item = Xrt.Repo.get(ActionItem, action_item_id)

    action_item
    |> ActionItem.changeset(%{completed: !action_item.completed})
    |> Xrt.Repo.update()
  end

  @spec find_retro_items(RetroItem.type(), Retro.t(), any(), any()) :: {:ok, list(RetroItem.t())}
  def find_retro_items(type, parent, _args, _resolution) do
    {:ok, Retros.find_retro_items(parent, type)}
  end

  @spec find_action_items(Retro.t(), any(), any()) :: {:ok, list(ActionItem.t())}
  def find_action_items(parent, _args, _resolution) do
    {:ok, Retros.find_action_items(parent)}
  end

  @spec authorized_title(RetroItem.t(), any(), context()) :: {:ok, String.t() | nil}
  def authorized_title(item, args, resolution) do
    case hidden_item?(item, args, resolution) do
      {:ok, false} -> {:ok, item.title}
      {:ok, true} -> {:ok, nil}
    end
  end

  @spec hidden_item?(RetroItem.t(), any(), context()) :: {:ok, boolean()}
  def hidden_item?(item, _args, %{context: context}) do
    with %Xrt.Retros.Retro{status: :initial} <- Xrt.Repo.get(Xrt.Retros.Retro, item.retro_id),
         false <- item.user_uuid == context.user_uuid do
      {:ok, true}
    else
      _ -> {:ok, false}
    end
  end

  @spec votes(RetroItem.t(), any(), any()) :: {:ok, integer()}
  def votes(item, _args, _resolution) do
    {:ok, Retros.vote_count(item)}
  end

  @spec add_vote(any(), %{item_id: RetroItem.id()}, context()) ::
          {:ok, RetroItem.t()} | {:error, any()}
  def add_vote(_parent, %{item_id: item_id}, %{context: context}) do
    Retros.add_vote(%{id: item_id}, context.user_uuid)
  end

  @spec next_step(any(), %{slug: Retro.slug()}, any()) :: {:ok, Retro.t()} | {:error, any()}
  def next_step(_parent, %{slug: slug}, _) do
    slug
    |> Retros.find_retro()
    |> Retros.transition_to_next_step()
  end

  @spec retro_updated_trigger(
          %{slug: Retro.slug()}
          | %{retro_item_id: RetroItem.id()}
          | %{retro_id: Retro.id()}
        ) :: String.t()
  def retro_updated_trigger(%{slug: slug}), do: slug

  def retro_updated_trigger(%{retro_item_id: retro_item_id}) do
    Xrt.Repo.get(RetroItem, retro_item_id)
    |> retro_updated_trigger()
  end

  def retro_updated_trigger(%{retro_id: retro_id}) do
    retro = Xrt.Repo.get(Retro, retro_id)

    retro.slug
  end

  def retro_updated_trigger(%Retro{} = retro) do
    retro.slug
  end

  @spec retro_updated(RetroItemVote.t() | %{retro_id: Retro.id()} | Retro.t(), any(), any()) ::
          {:ok, Retro.t()}
  def retro_updated(%RetroItemVote{retro_item_id: retro_item_id}, args, resolution) do
    RetroItem
    |> Xrt.Repo.get(retro_item_id)
    |> retro_updated(args, resolution)
  end

  def retro_updated(%{retro_id: retro_id}, args, resolution) do
    retro_id
    |> Retros.find_retro()
    |> retro_updated(args, resolution)
  end

  def retro_updated(%Retro{} = retro, args, _resolution) do
    {password, _} = Map.pop(args, :password, nil)

    case check_password({:ok, retro}, password) do
      {:ok, retro} ->
        {:ok, retro}

      error ->
        error
    end
  end

  @spec subscribe_to_retro_updated(%{slug: Retro.slug()}, any()) ::
          {:ok, topic: String.t()} | {:error, any()}
  def subscribe_to_retro_updated(args, _res) do
    {password, args} = Map.pop(args, :password, nil)

    args
    |> do_find_retro()
    |> check_password(password)
    |> case do
      {:ok, %Retro{slug: slug}} ->
        {:ok, topic: slug}

      error ->
        error
    end
  end

  defp do_find_retro(%{slug: slug, previous_retro_id: previous_retro_id})
       when not is_nil(previous_retro_id) do
    Retros.find_or_create_by_slug(slug, previous_retro_id: previous_retro_id)
  end

  defp do_find_retro(%{slug: slug}) do
    Retros.find_or_create_by_slug(slug)
  end

  defp check_password({:ok, retro}, password) do
    if Retros.correct_password?(retro, password) do
      {:ok, retro}
    else
      {:error, Errors.error(:unauthorized, "This retro is protected by a password")}
    end
  end

  defp check_password(result, _) do
    result
  end
end
