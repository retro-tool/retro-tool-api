defmodule XrtWeb.Graphql.QueryTest do
  use XrtWeb.ConnCase

  import Plug.Test
  import Xrt.Factory

  def run(query) do
    build_conn() |> init_test_session(%{}) |> post("/api/graph", query: query)
  end

  describe "retro" do
    test "returns a retro" do
      retro = insert(:retro)
      %{slug: slug} = retro
      retro_item = insert(:retro_item, type: :works, retro: retro)
      insert(:retro_item, type: :works, retro: retro, parent_retro_item: retro_item)

      conn =
        run("""
        query {
          retro(slug: "#{slug}") {
            slug
            works {
              title
              similarItems {
                title
              }
            }
            improve {
              title
              similarItems {
                id
              }
            }
            others {
              title
              similarItems {
                id
              }
            }
            actionItems { title }
          }
        }
        """)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "retro" => %{
                   "slug" => slug,
                   "works" => [%{"similarItems" => [%{"title" => nil}], "title" => nil}],
                   "improve" => [],
                   "others" => [],
                   "actionItems" => []
                 }
               }
             }
    end
  end

  describe "createWorksItem" do
    test "creates a retro item of type :works" do
      %{id: retro_id, slug: slug} = insert(:retro)

      title = "Sample title"

      conn =
        run("""
        mutation {
          createWorksItem(retro_slug: "#{slug}", title: "#{title}") {
            id
            title
            type
            ref
          }
        }
        """)

      assert %{
               "data" => %{
                 "createWorksItem" => %{
                   "id" => id,
                   "title" => ^title,
                   "type" => "works",
                   "ref" => "00"
                 }
               }
             } = json_response(conn, 200)

      retro_item = Xrt.Repo.get(Xrt.Retros.RetroItem, id)

      assert %Xrt.Retros.RetroItem{title: ^title, retro_id: ^retro_id, type: :works} = retro_item
    end
  end

  describe "createImproveItem" do
    test "createas a retro item of type :improve" do
      %{id: retro_id, slug: slug} = insert(:retro)

      title = "Sample title"

      conn =
        run("""
        mutation {
          createImproveItem(retro_slug: "#{slug}", title: "#{title}") {
            id
            title
            type
            ref
          }
        }
        """)

      assert %{
               "data" => %{
                 "createImproveItem" => %{
                   "id" => id,
                   "title" => ^title,
                   "type" => "improve",
                   "ref" => "00"
                 }
               }
             } = json_response(conn, 200)

      retro_item = Xrt.Repo.get(Xrt.Retros.RetroItem, id)

      assert %Xrt.Retros.RetroItem{title: ^title, retro_id: ^retro_id, type: :improve} =
               retro_item
    end
  end

  describe "createOtherItem" do
    test "creates a retro item of type :other" do
      %{id: retro_id, slug: slug} = insert(:retro)

      title = "Sample title"

      conn =
        run("""
        mutation {
          createOtherItem(retro_slug: "#{slug}", title: "#{title}") {
            id
            title
            type
            ref
          }
        }
        """)

      assert %{
               "data" => %{
                 "createOtherItem" => %{
                   "id" => id,
                   "title" => ^title,
                   "type" => "other",
                   "ref" => "00"
                 }
               }
             } = json_response(conn, 200)

      retro_item = Xrt.Repo.get(Xrt.Retros.RetroItem, id)

      assert %Xrt.Retros.RetroItem{title: ^title, retro_id: ^retro_id, type: :other} = retro_item
    end
  end

  describe "createActionItem" do
    test "creates an action item" do
      %{id: retro_id, slug: slug} = insert(:retro)

      title = "Sample title"

      conn =
        run("""
        mutation {
          createActionItem(retro_slug: "#{slug}", title: "#{title}") {
            id
            title
            completed
          }
        }
        """)

      assert %{
               "data" => %{
                 "createActionItem" => %{
                   "completed" => false,
                   "id" => id,
                   "title" => ^title
                 }
               }
             } = json_response(conn, 200)

      action_item = Xrt.Repo.get(Xrt.Retros.ActionItem, id)

      assert %Xrt.Retros.ActionItem{title: ^title, retro_id: ^retro_id, completed: false} =
               action_item
    end
  end

  describe "addVote" do
    test "adds a vote to a retro item" do
      %{id: id} = insert(:retro_item)

      conn =
        run("""
        mutation {
          addVote(item_id: "#{id}") {
            id
          }
        }
        """)

      assert %{
               "data" => %{
                 "addVote" => %{
                   "id" => _
                 }
               }
             } = json_response(conn, 200)
    end
  end

  describe "nextStep" do
    test "transitions retro to next step" do
      %{slug: slug} = insert(:retro, status: :initial)

      conn =
        run("""
        mutation {
          nextStep(slug: "#{slug}") {
            status
          }
        }
        """)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "nextStep" => %{
                   "status" => "review"
                 }
               }
             }
    end
  end

  describe "combineItems" do
    test "returns ok response" do
      parent = insert(:retro_item)
      child = insert(:retro_item)

      conn =
        run("""
        mutation {
          combineItems(parent_id: "#{parent.id}", child_id: "#{child.id}") {
            id
          }
        }
        """)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "combineItems" => %{"id" => child.id |> to_string}
               }
             }
    end
  end

  describe "detachItem" do
    test "returns ok response" do
      child = insert(:retro_item)

      conn =
        run("""
        mutation {
          detachItem(id: "#{child.id}") {
            id
          }
        }
        """)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "detachItem" => %{"id" => child.id |> to_string}
               }
             }
    end
  end

  describe "removeItem" do
    test "returns ok response" do
      item = insert(:retro_item)

      conn =
        run("""
        mutation {
          removeItem(id: "#{item.id}") {
            id
          }
        }
        """)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "removeItem" => %{"id" => item.id |> to_string}
               }
             }
    end
  end

  describe "removeActionItem" do
    test "returns ok response" do
      item = insert(:action_item)

      conn =
        run("""
        mutation {
          removeActionItem(id: "#{item.id}") {
            id
          }
        }
        """)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "removeActionItem" => %{"id" => item.id |> to_string}
               }
             }
    end
  end
end
