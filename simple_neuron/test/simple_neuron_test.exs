defmodule SimpleNeuronTest do
  use ExUnit.Case
  doctest SimpleNeuron

  test "create a neuron process" do
    assert SimpleNeuron.create() == true
  end

  test "send data to neurons" do
    assert SimpleNeuron.sense([1,2]) == :ok
  end

end
