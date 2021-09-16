defmodule Genetic do
  def run(fitness_function, genotype, max_fitness, opts \\ []) do
    initialize(genotype)
    |> evolve(fitness_function, max_fitness, opts)
  end

  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for(_ <- 1..population_size, do: genotype.())
  end

  def evolve(population, fitness_function, max_fitness, opts \\ []) do
    population = evaluate(population, fitness_function, opts)

    best = hd(population)
    IO.puts("\rCurrent Best: #{inspect(fitness_function.(best))}")

    if fitness_function.(best) >=
      max_fitness do
        best
      else
        population
        |> select(opts)
        |> crossover(opts)
        |> mutation(opts)
        |> evolve(fitness_function, max_fitness, opts)
      end
  end

  def evaluate(population, fitness_function, _opts \\ []) do
    population
    |> Enum.sort_by(fitness_function, &>=/2)
  end

  def select(population, _opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  def crossover(population, _opts \\ []) do
    Enum.reduce(population, [], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1))
      {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
      [h1 ++ t2, h2 ++ t1 | acc]
    end)
  end

  def mutation(population, opts \\ []) do
    mutation_rate = Keyword.get(opts, :mutation_rate, 0.05)
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_rate do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
