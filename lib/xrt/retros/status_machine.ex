defmodule Xrt.Retros.StatusMachine do
  @moduledoc """
  State machine to transition retros through phases.
  """

  alias Xrt.Repo
  alias Xrt.Retros.Retro

  @status_transitions %{
    initial: :review,
    review: :actions,
    actions: :final
  }

  @spec transition_to_next_step(Retro.t()) ::
          {:ok, Retro.t()} | {:error, :no_next_step_found} | {:error, any()}
  def transition_to_next_step(retro) do
    case find_next_step(retro) do
      {:error, _} ->
        {:error, :no_next_step_found}

      next_status ->
        retro
        |> Retro.changeset(%{status: next_status})
        |> Repo.update()
    end
  end

  @spec find_next_step(Retro.t()) :: :review | :actions | :final | {:error, atom()}
  def find_next_step(%Retro{status: status}) do
    Map.get(@status_transitions, status, {:error, status})
  end
end
