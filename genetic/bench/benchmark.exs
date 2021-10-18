defmodule DummyProblem do
  @behavior Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..100, do: Enum.random(0..1)
    Chromosome.new(genes: genes, size: 100)
  end

  @impl true
  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  @impl true
  def terminate?(_poputlation, generation), do: generation == 1
end

# It defines required variables.
dummy_population = Genetic.initialize(&DummyProblem.genotype/0, population_size: 100)
{dummy_selected_population, _parents, _leftover} = Genetic.select(dummy_population, selection_rate: 1.0)

Benchee.run(
  %{
    "initialize" => fn -> Genetic.initialize(&DummyProblem.genotype/0) end,
    "evaluate" => fn -> Genetic.evaluate(dummy_population, &DummyProblem.fitness_function/1) end,
    "select" => fn -> Genetic.select(dummy_population) end,
    "crossover" => fn -> Genetic.crossover(dummy_selected_population) end,
    "mutation" => fn -> Genetic.mutation(dummy_population) end,
    "evolve" => fn -> Genetic.evolve(dummy_population, DummyProblem, 0) end
  },
  memory_time: 2
)
