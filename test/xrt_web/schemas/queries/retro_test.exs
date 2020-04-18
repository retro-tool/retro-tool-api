defmodule XrtWeb.Schemas.Queries.RetroTest do
  use XrtWeb.GraphqlCase

  import Plug.Test
  import Xrt.Factory

  alias Xrt.Repo
  alias Xrt.Retros.Retro

  setup do
    %{conn: build_conn() |> init_test_session(%{})}
  end

  describe "retro" do
    @query """
      query getRetro($slug: String!) {
        retro(slug: $slug) {
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
    """

    test "returns an existing retro", %{conn: conn} do
      retro = insert(:retro)
      retro_item = insert(:retro_item, type: :works, retro: retro)
      insert(:retro_item, type: :works, retro: retro, parent_retro_item: retro_item)

      result =
        conn
        |> run(@query, %{slug: retro.slug})
        |> query_result()

      assert result == %{
               "data" => %{
                 "retro" => %{
                   "slug" => retro.slug,
                   "works" => [%{"similarItems" => [%{"title" => nil}], "title" => nil}],
                   "improve" => [],
                   "others" => [],
                   "actionItems" => []
                 }
               }
             }
    end
  end

  test "it creates the retro if it doesn't exist", %{conn: conn} do
    slug = "custom-slug"

    result =
      conn
      |> run(@query, %{slug: slug})
      |> query_result()

    assert result == %{
             "data" => %{
               "retro" => %{
                 "slug" => slug,
                 "works" => [],
                 "improve" => [],
                 "others" => [],
                 "actionItems" => []
               }
             }
           }

    assert %Retro{slug: ^slug} = Repo.get_by(Retro, slug: slug)
  end
end
