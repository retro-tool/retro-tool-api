defmodule XrtWeb.Schemas.Queries.UserTest do
  use XrtWeb.GraphqlCase

  describe "currentUser" do
    @query """
    query {
      currentUser {
        uuid
      }
    }
    """

    test "returns the uuid for the user" do
      result =
        build_conn()
        |> run(@query)
        |> query_result()

      assert %{
               "data" => %{
                 "currentUser" => %{
                   "uuid" => uuid
                 }
               }
             } = result
    end
  end

  describe "currentUser for slug (DEPRECATED)" do
    @query """
    query currentUser($slug: String) {
      currentUser(retroSlug: $slug) {
        uuid
      }
    }
    """

    test "returns the uuid for the user" do
      result =
        build_conn()
        |> run(@query, %{slug: "non-existing-retro"})
        |> query_result()

      assert %{
               "data" => %{
                 "currentUser" => %{
                   "uuid" => uuid
                 }
               }
             } = result

      assert uuid != nil
    end
  end
end
