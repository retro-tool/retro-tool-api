defmodule Xrt.Monitoring.Measurements do
  @moduledoc """
  Telemetry measurements.
  """

  alias Xrt.Repo
  alias Xrt.Retros.{Retro, RetroItem}

  @spec retro_count() :: any()
  def retro_count do
    count = Repo.aggregate(Retro, :count)
    :telemetry.execute([:retro, :retro], %{count: count}, %{})
  end

  @spec retro_items_count() :: any()
  def retro_items_count do
    count = Repo.aggregate(RetroItem, :count)
    :telemetry.execute([:retro, :retro_item], %{count: count}, %{})
  end
end
