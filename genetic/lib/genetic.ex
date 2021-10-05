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
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      children ++ leftover
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

  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/2)

    select_rate = Keyword.get(opts, :selection_rate, 0.8)

    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n + 1

    parents =
      select_fn
      |> apply([population, n])

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    {parents, MapSet.to_list(leftover)}
  end

  def crossover(population, opts \\ []) do
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.single_point/3)
    crossover_rate = Keyword.get(opts, :crossover_rate, 0.5)
    chromosome_repair = Keyword.get(opts, :chromosome_repair, false)

    new_generation =
      Enum.reduce(population, [], fn {p1, p2}, acc ->
        {c1, c2} = apply(crossover_fn, [p1, p2, crossover_rate])
        [c1, c2 | acc]
      end)

    if chromosome_repair,
      do: Enum.map(new_generation, &repair_chromosome(&1)),
      else: new_generation
  end

  def mutation(population, opts \\ []) do
    mutation_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.scramble/2)
    mutation_rate = Keyword.get(opts, :mutation_rate, 0.05)
    mutation_args = Keyword.get(opts, :mutation_args, 0.05)

    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_rate do
        apply(mutation_fn, [chromosome, mutation_args])
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end

  defp repair_chromosome(chromosomes) do
    new_genes =
      chromosomes.genes
      |> MapSet.new()
      |> repair_helper(chromosomes.size)
    %Chromosome{chromosomes | genes: new_genes}
  end

  defp repair_helper(chromosome, k) do
    if MapSet.size(chromosome) >= k do
      MapSet.to_list(chromosome)
    else
      num = :rand.uniform(8) - 1
      repair_helper(MapSet.put(chromosome, num), k)
    end
  end
end
