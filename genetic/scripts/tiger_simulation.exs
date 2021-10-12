defmodule TigerSimulation do
  @behaviour Problem
  alias Types.Chromosome

  @tropic_scores [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
  @tundra_scores [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]

  @impl true
  def genotype() do
    genes = for _ <- 1..8, do: Enum.random(0..1)
    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl true
  def fitness_function(chromosome) do

    traits = chromosome.genes

    traits
    #|> Enum.zip(@tropic_scores)
    |> Enum.zip(@tundra_scores)
    |> Enum.map(fn {t, s} -> t*s end)
    |> Enum.sum()
  end

  @impl true
  def terminate?(_population, generation) do
    generation == 1000
  end

  def average_tiger(population) do
    genes = Enum.map(population, & &1.genes)
    fitnesses = Enum.map(population, & &1.fitness)
    ages = Enum.map(population, & &1.age)
    num_tigers = length(population)

    avg_fitness = Enum.sum(fitnesses) / num_tigers
    avg_age = Enum.sum(ages) / num_tigers
    avg_genes =
      genes
      |> Enum.zip()
      |> Enum.map(&Enum.sum(Tuple.to_list(&1)) / num_tigers)

    Chromosome.new(genes: avg_genes, age: avg_age, fitness: avg_fitness)
  end
end

soln = Genetic.run(TigerSimulation,
          population_size: 100,
          selection_rate: 0.9,
          mutation_rate: 0.1)

IO.inspect(soln)

{_, third_gen_stats} = Utilities.Statistics.lookup(3)

IO.puts("Min fitness after 3rd Generation: #{third_gen_stats.min_fitness}")

{_, zero_gen_stats} = Utilities.Statistics.lookup(0)
{_, fivehundred_gen_stats} = Utilities.Statistics.lookup(500)
{_, onethousand_gen_stats} = Utilities.Statistics.lookup(1000)

IO.puts("""
0th: #{zero_gen_stats.mean_fitness}
500th: #{fivehundred_gen_stats.mean_fitness}
1000th: #{onethousand_gen_stats.mean_fitness}
""")

soln = Genetic.run(TigerSimulation,
          population_size: 20,
          selection_rate: 0.9,
          mutation_rate: 0.1,
          statistics: %{average_tiger: &TigerSimulation.average_tiger/1})

IO.inspect(soln)

{_, zero_gen_stats} = Utilities.Statistics.lookup(0)
{_, fivehundred_gen_stats} = Utilities.Statistics.lookup(500)
{_, onethousand_gen_stats} = Utilities.Statistics.lookup(1000)

IO.inspect(zero_gen_stats.average_tiger, label: "0th")
IO.inspect(fivehundred_gen_stats.average_tiger, label: "500th")
IO.inspect(onethousand_gen_stats.average_tiger, label: "1000th")

genealogy = Utilities.Genealogy.get_tree()

IO.inspect(Graph.vertices(genealogy))
