defmodule BasicAnnTest do
  use ExUnit.Case
  doctest BasicAnn

  test "greets the world" do
    assert BasicAnn.hello() == :world
  end
end
