defmodule XrtWeb.SystemController do
  use XrtWeb, :controller

  @spec run(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    text(conn, "OK")
  end
end
