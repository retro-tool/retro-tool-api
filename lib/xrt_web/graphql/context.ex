defmodule XrtWeb.Graphql.Context do
  @moduledoc """
  Plug to enrich graphql context with session information.
  """

  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case get_session(conn, :user_uuid) do
      nil ->
        user_uuid = UUID.uuid4()
        conn |> put_session(:user_uuid, user_uuid) |> add_to_context(%{user_uuid: user_uuid})

      user_uuid ->
        add_to_context(conn, %{user_uuid: user_uuid})
    end
  end

  defp add_to_context(conn, context) do
    Absinthe.Plug.put_options(conn, context: context)
  end
end
