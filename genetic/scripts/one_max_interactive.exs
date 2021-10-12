defmodule OneMaxInteractive do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    genes = for _ <- 1..42, do: Enum.random(0..1)
    Chromosome.new(genes: genes, size: 42)
  end

  @impl true
  def fitness_function(chromosome) do
    IO.inspect(chromosome)
    "Rate from 1 to 10 "
    |> IO.gets()
    |> String.trim("\n")
    |> String.to_integer()
  end

  @impl true
  def terminate?(_population, generation), do: generation == 1
end

soln = Genetic.run(OneMaxInteractive, population_size: 2)

IO.inspect(soln)
