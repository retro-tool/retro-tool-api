defmodule XrtWeb.Resolvers.Stats do
  @moduledoc """
  Resolver functions for statistics.
  """

  alias Xrt.Retros

  @spec stats(any(), any(), any()) :: {:ok, map()}
  def stats(_parent, _args, _context) do
    {:ok,
     %{
       retros: retro_stats()
     }}
  end

  defp retro_stats do
    %{count: Retros.count()}
  end
end
