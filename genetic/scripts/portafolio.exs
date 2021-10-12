defmodule Portafolio do
  @behaviour Problem
  alias Types.Chromosome

  @target_fitness 180

  @impl true
  def genotype() do
    genes = for _ <- 1..10, do: {:rand.uniform(10), :rand.uniform(10)}
    Chromosome.new(genes: genes, size: 10)
  end

  @impl true
  def fitness_function(chromosome) do
    chromosome.genes
    |> Enum.map(fn {roi, risk} -> 2 * roi - risk end)
    |> Enum.sum()
  end

  @impl true
  def terminate?(population, _generation) do
    max_value = Enum.max_by(population, &Portafolio.fitness_function/1)
    max_value.fitness == @target_fitness
  end
end

soln = Genetic.run(Portafolio, population_size: 50, mutation_rate: 0.05)

IO.inspect(soln)
