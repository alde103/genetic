defmodule Codebreaker do
  @behaviour Problem
  alias Types.Chromosome
  use Bitwise

  @impl true
  def genotype do
    genes = for _ <- 1..64, do: Enum.random(0..1)
    Chromosome.new(genes: genes, size: 64)
  end

  @impl true
  def fitness_function(chromosome) do
    target = "ILoveGeneticAlgorithms"
    encrypted = 'LIjs`B`k`qlfDibjwlqmhv'
    cipher = fn word, key -> Enum.map(word, &rem( &1 ^^^ key, 32768)) end

    key =
      chromosome.genes
      |> Enum.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?([best | _] = _population, _generation) do
    best.fitness == 1
  end
end

soln = Genetic.run(Codebreaker, crossover_type: &Toolbox.Crossover.single_point/3)

IO.write("\n")
IO.inspect(soln)

{key, ""} =
  soln.genes
  |> Enum.map(&Integer.to_string(&1))
  |> Enum.join("")
  |> Integer.parse(2)
  |> IO.inspect()

cipher = fn word, key -> Enum.map(word, &rem( Bitwise.^^^(key, &1), 32768)) end

List.to_string(cipher.('LIjs`B`k`qlfDibjwlqmhv', key)) |> IO.puts()
