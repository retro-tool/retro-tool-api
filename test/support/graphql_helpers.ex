defmodule XrtWeb.GraphqlHelpers do
  @moduledoc """
  Helpers for Graphql related tests
  """

  import Phoenix.ConnTest

  @endpoint XrtWeb.Endpoint

  @spec run(Plug.Conn.t(), String.t(), map()) :: Plug.Conn.t()
  def run(conn, query, variables \\ %{}) do
    post(conn, "/api/graph", query: query, variables: variables)
  end

  @spec query_result(Plug.Conn.t()) :: map()
  def query_result(conn) do
    json_response(conn, 200)
  end
end
