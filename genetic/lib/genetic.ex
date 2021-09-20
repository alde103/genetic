defmodule Genetic do
  alias Types.Chromosome

  def run(problem, opts \\ []) do
    initialize(&problem.genotype/0, opts)
    |> evolve(problem, 0, opts)
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)

    best = hd(population)

    IO.puts("\rCurrent Best: #{inspect({best.fitness, best.genes})}")

    if problem.terminate?(population, generation) do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(problem, generation + 1, opts)
    end
  end

  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for(_ <- 1..population_size, do: genotype.())
  end

  def evaluate(population, fitness_function, _opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  def select(population, _opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  def crossover(population, _opts \\ []) do
    Enum.reduce(population, [], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1.genes))
      {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
      {c1, c2} = {%Chromosome{p1 | genes: h1 ++ t2}, %Chromosome{p2 | genes: h2 ++ t1}}
      [c1, c2 | acc]
    end)
  end

  def mutation(population, opts \\ []) do
    mutation_rate = Keyword.get(opts, :mutation_rate, 0.05)

    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_rate do
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end
end
