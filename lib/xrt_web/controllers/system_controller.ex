defmodule XrtWeb.SystemController do
  use XrtWeb, :controller

  def index(conn, _params) do
    text(conn, "OK")
  end
end
