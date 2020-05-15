defmodule XrtWeb.Resolvers.Users do
  @moduledoc """
  Resolver functions for fields, queries and mutations related to users.
  """

  @typep context :: %{context: %{user_uuid: String.t()}}

  @typep user :: %{uuid: String.t()}

  @spec current_user(any(), %{}, context()) :: {:ok, user()}
  def current_user(_parent, _params, %{context: %{user_uuid: user_uuid}}) do
    {:ok, build_user(user_uuid)}
  end

  defp build_user(user_uuid) do
    %{uuid: user_uuid}
  end
end
