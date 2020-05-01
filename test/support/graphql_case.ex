defmodule XrtWeb.GraphqlCase do
  @moduledoc """
  Helpers for graphql related tests
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use XrtWeb.ConnCase

      import XrtWeb.GraphqlHelpers
    end
  end
end
