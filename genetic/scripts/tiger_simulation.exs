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

import Gnuplot

tiger = Genetic.run(TigerSimulation,
                    population_size: 2,
                    selection_rate: 1.0,
                    mutation_rate: 0.0)


IO.write("\n")

genealogy = Utilities.Genealogy.get_tree()

{:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)
{:ok, dotfile} = File.open("tiger_simulation.dot", [:write])
:ok = IO.binwrite(dotfile, dot)
:ok = File.close(dotfile)

tiger = Genetic.run(TigerSimulation,
                    population_size: 50,
                    selection_rate: 0.8,
                    mutation_rate: 0.1)

stats =
  :ets.tab2list(:statistics)
  |> Enum.map(fn {gen, stats} -> [gen, stats.mean_fitness] end)
  |> Enum.sort_by(&(&1), :asc)

{:ok, cmd} =
  plot([
    [:set, :title, "mean fitness versus generation"],
    [:plot, "-", :with, :points]
    ], [stats])

IO.inspect(cmd)
