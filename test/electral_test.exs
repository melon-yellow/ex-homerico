defmodule ElectralTest do
  use ExUnit.Case
  doctest Electral

  test "greets the world" do
    assert Electral.hello() == :world
  end
end
