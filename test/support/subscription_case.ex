defmodule XrtWeb.SubscriptionCase do
  @moduledoc """
  This module defines the test case to be used by
  subscription tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      use XrtWeb.ChannelCase
      use Absinthe.Phoenix.SubscriptionTest, schema: XrtWeb.Schema
    end
  end
end
