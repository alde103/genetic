defmodule NQueens do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype, do: Chromosome.new(genes: Enum.shuffle(0..7), size: 8)

  @impl true
  def fitness_function(chromosome) do
    diag_clashes =
      for i <- 0..7, j <- 0..7 do
        if i != j do
          dx = abs(i - j)
          dy = abs(
            chromosome.genes
            |> Enum.at(i)
            |> Kernel.-(Enum.at(chromosome.genes, j))
          )
          if dx == dy do
            1
          else
            0
          end
        else
          0
        end
      end
    length(Enum.uniq(chromosome.genes)) - Enum.sum(diag_clashes)
  end

  @impl true
  #def terminate?([best | _tail], _generation), do: best.fitness == 8
  def terminate?(population, _generation), do: Enum.max_by(population, &NQueens.fitness_function/1).fitness == 8
end

soln = Genetic.run(NQueens, crossover_type: &Toolbox.Crossover.single_point/3, chromosome_repair: true)

IO.write("\n")
IO.inspect(soln)
