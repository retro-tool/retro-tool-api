defmodule XrtWeb.EndpointTest do
  use XrtWeb.GraphqlCase

  describe "rate limit" do
    @query """
    retro {
      slug
    }
    """
    test "only allows max of 10 requests each 10 seconds" do
      conn = build_conn()

      Enum.each(1..50, fn _ ->
        conn
        |> run(@query)
        |> assert_success()
      end)

      conn
      |> run(@query)
      |> assert_rate_limited()

      :timer.sleep(10_000)

      conn
      |> run(@query)
      |> assert_success()
    end

    defp assert_success(conn) do
      assert conn.status == 200

      conn
    end

    defp assert_rate_limited(conn) do
      assert conn.status == 429

      conn
    end
  end
end
