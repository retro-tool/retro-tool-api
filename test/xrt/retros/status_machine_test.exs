defmodule Xrt.Retros.StatusMachineTest do
  use Xrt.DataCase

  import Xrt.Factory

  alias Xrt.Retros.{Retro, StatusMachine}

  describe "transition_to_next_step/1" do
    test "transitions from initial to review" do
      retro = insert(:retro, status: :initial)

      assert {:ok, %Retro{status: :review}} = StatusMachine.transition_to_next_step(retro)
    end

    test "transitions from review to actions" do
      retro = insert(:retro, status: :review)

      assert {:ok, %Retro{status: :actions}} = StatusMachine.transition_to_next_step(retro)
    end

    test "transitions from actions to final" do
      retro = insert(:retro, status: :actions)

      assert {:ok, %Retro{status: :final}} = StatusMachine.transition_to_next_step(retro)
    end

    test "can't transtion from final" do
      retro = insert(:retro, status: :final)

      assert {:error, :no_next_step_found} = StatusMachine.transition_to_next_step(retro)
    end
  end
end
