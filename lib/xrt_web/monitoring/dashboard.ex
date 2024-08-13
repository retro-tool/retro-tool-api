defmodule XrtWeb.Monitoring.Dashboard do
  @moduledoc """
  Telemetry setup for the phoenix live dashboard.
  """
  use Supervisor
  import Telemetry.Metrics

  @spec start_link(any()) :: {:ok, pid()} | {:error, any()}
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec metrics() :: list()
  def metrics do
    [
      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),
      # Absinthe metrics
      summary("absinthe.execute.operation.stop.duration", unit: {:native, :millisecond}),
      # Domain metrics
      last_value("retro.retro.count"),
      last_value("retro.retro_item.count")
    ]
  end

  defp periodic_measurements do
    [
      {Xrt.Monitoring.Measurements, :retro_count, []},
      {Xrt.Monitoring.Measurements, :retro_items_count, []}
    ]
  end
end
