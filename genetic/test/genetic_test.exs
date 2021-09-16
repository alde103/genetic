defmodule GeneticTest do
  use ExUnit.Case
  doctest Genetic

  test "greets the world" do
    assert Genetic.hello() == :world
  end
end
