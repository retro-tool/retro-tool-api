defmodule XrtWeb.Schemas.Mutations.RetroTest do
  use XrtWeb.GraphqlCase

  import Plug.Test
  import Xrt.Factory

  alias Xrt.Repo
  alias Xrt.Retros
  alias Xrt.Retros.{ActionItem, RetroItem}

  setup do
    %{conn: build_conn() |> init_test_session(%{})}
  end

  describe "createWorksItem" do
    @query """
      mutation createWorksItem($slug: String!, $title: String!) {
        createWorksItem(retro_slug: $slug, title: $title) {
          id
          title
          type
          ref
        }
      }
    """

    test "creates a retro item of type :works", %{conn: conn} do
      retro = insert(:retro)
      title = "Sample title"

      result =
        conn
        |> run(@query, %{slug: retro.slug, title: title})
        |> query_result()

      assert %{
               "data" => %{
                 "createWorksItem" => %{
                   "id" => id,
                   "title" => ^title,
                   "type" => "works",
                   "ref" => "00"
                 }
               }
             } = result

      retro_item = Repo.get(RetroItem, id)

      retro_id = retro.id
      assert %RetroItem{title: ^title, retro_id: ^retro_id, type: :works} = retro_item
    end
  end

  describe "createImproveItem" do
    @query """
      mutation createImproveItem($slug: String!, $title: String!) {
        createImproveItem(retro_slug: $slug, title: $title) {
          id
          title
          type
          ref
        }
      }
    """

    test "createas a retro item of type :improve", %{conn: conn} do
      retro = insert(:retro)
      title = "Sample title"

      result =
        conn
        |> run(@query, %{slug: retro.slug, title: title})
        |> query_result()

      assert %{
               "data" => %{
                 "createImproveItem" => %{
                   "id" => id,
                   "title" => ^title,
                   "type" => "improve",
                   "ref" => "00"
                 }
               }
             } = result

      retro_item = Xrt.Repo.get(RetroItem, id)

      retro_id = retro.id

      assert %RetroItem{title: ^title, retro_id: ^retro_id, type: :improve} = retro_item
    end
  end

  describe "createOtherItem" do
    @query """
      mutation createOtherItem($slug: String!, $title: String!) {
        createOtherItem(retro_slug: $slug, title: $title) {
          id
          title
          type
          ref
        }
      }
    """

    test "creates a retro item of type :other", %{conn: conn} do
      retro = insert(:retro)
      title = "Sample title"

      result =
        conn
        |> run(@query, %{slug: retro.slug, title: title})
        |> query_result()

      assert %{
               "data" => %{
                 "createOtherItem" => %{
                   "id" => id,
                   "title" => ^title,
                   "type" => "other",
                   "ref" => "00"
                 }
               }
             } = result

      retro_item = Xrt.Repo.get(RetroItem, id)

      retro_id = retro.id
      assert %RetroItem{title: ^title, retro_id: ^retro_id, type: :other} = retro_item
    end
  end

  describe "createActionItem" do
    @query """
      mutation createActionItem($slug: String!, $title: String!) {
        createActionItem(retro_slug: $slug, title: $title) {
          id
          title
          completed
        }
      }
    """
    test "creates an action item", %{conn: conn} do
      retro = insert(:retro)
      title = "Sample title"

      result =
        conn
        |> run(@query, %{slug: retro.slug, title: title})
        |> query_result()

      assert %{
               "data" => %{
                 "createActionItem" => %{
                   "completed" => false,
                   "id" => id,
                   "title" => ^title
                 }
               }
             } = result

      action_item = Xrt.Repo.get(ActionItem, id)

      retro_id = retro.id

      assert %ActionItem{title: ^title, retro_id: ^retro_id, completed: false} = action_item
    end
  end

  describe "addVote" do
    @query """
      mutation addVote($id: ID!) {
        addVote(item_id: $id) {
          id
        }
      }
    """

    test "adds a vote to a retro item", %{conn: conn} do
      retro_item = insert(:retro_item)

      assert 0 == Retros.vote_count(retro_item)

      result =
        conn
        |> run(@query, %{id: retro_item.id})
        |> query_result()

      assert %{
               "data" => %{
                 "addVote" => %{
                   "id" => _
                 }
               }
             } = result

      assert 1 == Retros.vote_count(retro_item)
    end
  end

  describe "nextStep" do
    @query """
      mutation nextStep($slug: String!) {
        nextStep(slug: $slug) {
          status
        }
      }
    """

    test "transitions retro to next step", %{conn: conn} do
      retro = insert(:retro, status: :initial)

      result =
        conn
        |> run(@query, %{slug: retro.slug})
        |> query_result()

      assert result == %{
               "data" => %{
                 "nextStep" => %{
                   "status" => "review"
                 }
               }
             }
    end
  end

  describe "combineItems" do
    @query """
      mutation combineItems($parent_id: String!, $child_id: String!) {
        combineItems(parent_id: $parent_id, child_id: $child_id) {
          id
        }
      }
    """

    test "combines items", %{conn: conn} do
      %{id: parent_id} = insert(:retro_item)
      %{id: child_id, parent_retro_item_id: nil} = insert(:retro_item)

      result =
        conn
        |> run(@query, %{parent_id: to_string(parent_id), child_id: to_string(child_id)})
        |> query_result()

      assert result == %{
               "data" => %{
                 "combineItems" => %{"id" => child_id |> to_string}
               }
             }

      assert %RetroItem{parent_retro_item_id: ^parent_id} = Repo.get(RetroItem, child_id)
    end
  end

  describe "detachItem" do
    @query """
      mutation detachItem($id: String!) {
        detachItem(id: $id) {
          id
        }
      }
    """

    test "detaches an item from the parent", %{conn: conn} do
      %{id: parent_id} = insert(:retro_item)
      %{id: child_id} = insert(:retro_item, parent_retro_item_id: parent_id)

      result =
        conn
        |> run(@query, %{id: to_string(child_id)})
        |> query_result()

      assert result == %{
               "data" => %{
                 "detachItem" => %{"id" => to_string(child_id)}
               }
             }

      assert %RetroItem{parent_retro_item_id: nil} = Repo.get(RetroItem, child_id)
    end
  end

  describe "removeItem" do
    @query """
      mutation removeItem($id: String!) {
        removeItem(id: $id) {
          id
        }
      }
    """

    test "removes an item", %{conn: conn} do
      item = insert(:retro_item)

      result =
        conn
        |> run(@query, %{id: to_string(item.id)})
        |> query_result()

      assert result == %{
               "data" => %{
                 "removeItem" => %{"id" => to_string(item.id)}
               }
             }

      assert nil == Repo.get(RetroItem, item.id)
    end
  end

  describe "removeActionItem" do
    @query """
      mutation removeActionItem($id: String!) {
        removeActionItem(id: $id) {
          id
        }
      }
    """
    test "returns ok response", %{conn: conn} do
      item = insert(:action_item)

      result =
        conn
        |> run(@query, %{id: to_string(item.id)})
        |> query_result()

      assert result == %{
               "data" => %{
                 "removeActionItem" => %{"id" => to_string(item.id)}
               }
             }

      assert nil == Repo.get(ActionItem, item.id)
    end
  end
end
