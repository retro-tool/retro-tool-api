defmodule XrtWeb.GraphqlCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use XrtWeb.ConnCase

      import Plug.Test

      defp run(conn, query, variables \\ %{}) do
        post(conn, "/api/graph", query: query, variables: variables)
      end

      def query_result(conn) do
        json_response(conn, 200)
      end
    end
  end
end
