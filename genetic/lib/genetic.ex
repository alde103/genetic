defmodule Genetic do
  alias Types.Chromosome

  def run(problem, opts \\ []) do
    initialize(&problem.genotype/0, opts)
    |> evolve(problem, 0, opts)
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)

    best = hd(population)

    IO.puts(
      "\rCurrent Best: #{inspect({best.fitness, best.genes, best.age, length(population)})}"
    )

    if problem.terminate?(population, generation) do
      best
    else
      {paired_parents, parents, leftover} = select(population, opts)
      children = crossover(paired_parents, opts)
      mutants = mutation(population, opts)
      offspring = Enum.drop(children, Enum.count(mutants)) ++ mutants
      new_population = reinsertion(parents, offspring, leftover, opts)
      evolve(new_population, problem, generation + 1, opts)
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
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/3)

    select_rate = Keyword.get(opts, :selection_rate, 0.8)

    tournsize = Keyword.get(opts, :selection_tournsize, 4)

    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n + 1

    parents =
      select_fn
      |> apply([population, n, tournsize])

    leftover = Enum.reduce(parents, population, fn parent, acc -> acc -- [parent] end)

    paired_parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    {paired_parents, parents, leftover}
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

    n = floor(length(population) * mutation_rate)

    population
    |> Enum.take_random(n)
    |> Enum.map(fn chromosome ->
      new_chromosome = apply(mutation_fn, [chromosome, mutation_args])
      %Chromosome{chromosome | genes: new_chromosome.genes}
    end)
  end

  def reinsertion(parents, offspring, leftover, opts \\ []) do
    strategy = Keyword.get(opts, :reinsertion_strategy, &Toolbox.Reinsertion.pure/4)
    survival_rate = Keyword.get(opts, :survival_rate, 0.2)
    apply(strategy, [parents, offspring, leftover, survival_rate])
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
