defmodule Speller do
  @behaviour Problem
  alias Types.Chromosome

  @target 'awesome'
  #@target 'supercalifragilisticexpialidocious'

  @impl true
  def genotype() do
    size = length(@target)
    genes = Stream.repeatedly(fn -> Enum.random(?a..?z) end) |> Enum.take(size)
    Chromosome.new(genes: genes, size: size)
  end

  @impl true
  def fitness_function(chromosome) do
    target = List.to_string(@target)
    guess = List.to_string(chromosome.genes)
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?([best | _tail], _generation), do: best.fitness == 1
end

soln = Genetic.run(Speller, population_size: 1000, mutation_rate: 0.05)
# soln = Genetic.run(Speller,
#         population_size: 500,
#         reinsertion_strategy: &Toolbox.Reinsertion.elitist/5,
#         crossover_type: &Toolbox.Crossover.uniform/3,
#         selection_type: &Toolbox.Selection.tournament_no_duplicates/3,
#         mutatuion_type: &Toolbox.Mutation.scramble/2,
#         mutation_rate: 0.1
#         )

IO.inspect(soln)
