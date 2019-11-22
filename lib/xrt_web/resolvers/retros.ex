defmodule XrtWeb.Resolvers.Retros do
  alias Xrt.Retros
  alias Xrt.Retros.{Retro, RetroItem, RetroItemVote, ActionItem}

  def find_retro(_parent, options \\ %{}, _resolution) do
    slug = options |> Map.get(:slug)
    previous_retro_id = options |> Map.get(:previous_retro_id)
    Retros.find_or_create_by_slug(slug, previous_retro_id: previous_retro_id)
  end

  def find_previous_retro(parent, %{}, _resolution) do
    Retros.find_previous_retro(parent)
  end

  def add_works_item(_parent, args, %{context: context}) do
    args
    |> Map.put(:type, :works)
    |> create_retro_item(context)
  end

  def add_improve_item(_parent, args, %{context: context}) do
    args
    |> Map.put(:type, :improve)
    |> create_retro_item(context)
  end

  def add_other_item(_parent, args, %{context: context}) do
    args
    |> Map.put(:type, :other)
    |> create_retro_item(context)
  end

  defp create_retro_item(%{retro_slug: slug, title: title, type: type}, %{user_uuid: user_uuid}) do
    slug
    |> Retros.find_retro()
    |> Retros.add_item(%{title: title, type: type, user_uuid: user_uuid})
  end

  def add_action_item(_parent, %{retro_slug: slug, title: title}, _context) do
    slug
    |> Retros.find_retro()
    |> Retros.add_action_item(%{title: title})
  end

  def combine_items(_parent, %{parent_id: parent_id, child_id: child_id}, _context) do
    Xrt.Retros.set_parent_id(child_id, parent_id)
  end

  def detach_item(_parent, %{id: id}, _context) do
    Xrt.Retros.set_parent_id(id, nil)
  end

  def remove_item(_parent, %{id: id}, _context) do
    Xrt.Retros.remove_item(id)
  end

  def remove_action_item(_parent, %{id: id}, _context) do
    Xrt.Retros.remove_action_item(id)
  end

  def find_similar_items(parent, _args, _resolution) do
    {:ok, Retros.find_similar_items(parent)}
  end

  def toggle_completed(_parent, %{action_item_id: action_item_id}, _resolution) do
    action_item = Xrt.Repo.get(ActionItem, action_item_id)

    action_item
    |> ActionItem.changeset(%{completed: !action_item.completed})
    |> Xrt.Repo.update()
  end

  def find_retro_items(type, parent, _args, _resolution) do
    {:ok, Retros.find_retro_items(parent, type)}
  end

  def find_action_items(parent, _args, _resolution) do
    {:ok, Retros.find_action_items(parent)}
  end

  def authorized_title(item, args, resolution) do
    case hidden_item?(item, args, resolution) do
      {:ok, false} -> {:ok, item.title}
      {:ok, true} -> {:ok, nil}
    end
  end

  def hidden_item?(item, _args, %{context: context}) do
    with %Xrt.Retros.Retro{status: :initial} <- Xrt.Repo.get(Xrt.Retros.Retro, item.retro_id),
         false <- item.user_uuid == context.user_uuid do
      {:ok, true}
    else
      _ -> {:ok, false}
    end
  end

  def votes(item, _args, _resolution) do
    {:ok, Retros.vote_count(item)}
  end

  def add_vote(_parent, %{item_id: item_id}, %{context: context}) do
    Retros.add_vote(%{id: item_id}, context.user_uuid)
  end

  def next_step(_parent, %{slug: slug}, _) do
    slug
    |> Retros.find_retro()
    |> Retros.transition_to_next_step()
  end

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

  def retro_updated(%RetroItemVote{retro_item_id: retro_item_id}, _args, _resolution) do
    %RetroItem{retro_id: retro_id} = Xrt.Repo.get(RetroItem, retro_item_id)
    {:ok, Xrt.Repo.get(Retro, retro_id)}
  end

  def retro_updated(%{retro_id: retro_id}, _args, _resolution) do
    {:ok, Xrt.Repo.get(Xrt.Retros.Retro, retro_id)}
  end

  def retro_updated(%Retro{} = retro, _args, _resolution) do
    {:ok, retro}
  end
end
