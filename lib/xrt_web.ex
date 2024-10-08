defmodule XrtWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use XrtWeb, :controller
      use XrtWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  @spec controller() :: any()
  def controller do
    quote do
      use Phoenix.Controller, namespace: XrtWeb

      import Plug.Conn
      import XrtWeb.Gettext
      alias XrtWeb.Router.Helpers, as: Routes
    end
  end

  @spec view() :: any()
  def view do
    quote do
      use Phoenix.View,
        root: "lib/xrt_web/templates",
        namespace: XrtWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      import XrtWeb.ErrorHelpers
      import XrtWeb.Gettext
      alias XrtWeb.Router.Helpers, as: Routes
    end
  end

  @spec router() :: any()
  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @spec channel() :: any()
  def channel do
    quote do
      use Phoenix.Channel
      import XrtWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
