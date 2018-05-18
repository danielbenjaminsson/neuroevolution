defmodule SimplestNnTest do
  use ExUnit.Case
  doctest SimplestNn

  test "create a neuron process" do
    assert SimplestNn.create() == true
  end

end
