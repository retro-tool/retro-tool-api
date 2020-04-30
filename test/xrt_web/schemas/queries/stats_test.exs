defmodule XrtWeb.Schemas.Queries.StatsTest do
  use XrtWeb.GraphqlCase

  import Xrt.Factory

  describe "stats" do
    @query """
    query {
      stats {
        retros {
          count
        }
      }
    }
    """
    test "returns retro count" do
      insert_list(4, :retro)

      result =
        build_conn()
        |> run(@query)
        |> query_result()

      assert result == %{
               "data" => %{
                 "stats" => %{
                   "retros" => %{
                     "count" => 4
                   }
                 }
               }
             }
    end
  end
end
