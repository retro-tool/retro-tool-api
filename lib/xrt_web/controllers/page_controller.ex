defmodule XrtWeb.PageController do
  use XrtWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
