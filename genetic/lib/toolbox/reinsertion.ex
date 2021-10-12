defmodule Toolbox.Reinsertion do
  def pure(parents, offspring, leftovers, _survival_rate, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    old_generation = parents ++ leftovers
    new_generation = offspring ++ leftovers
    force_fixed_population_size(new_generation, old_generation, population_size - length(new_generation))
  end

  def elitist(parents, offspring, leftovers, survival_rate, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    old_generation = parents ++ leftovers
    n = floor(length(old_generation) * survival_rate)

    survivors =
      old_generation
      |> Enum.sort_by(& &1.fitness, &>=/2)
      |> Enum.take(n)

    new_generation = offspring ++ survivors
    force_fixed_population_size(new_generation, old_generation, population_size - length(new_generation))
  end

  def uniform(parents, offspring, leftovers, survival_rate, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    old_generation = parents ++ leftovers
    n = floor(length(old_generation) * survival_rate)
    survivors = Enum.take_random(old_generation, n)
    new_generation = offspring ++ survivors
    force_fixed_population_size(new_generation, old_generation, population_size - length(new_generation))
  end

  defp force_fixed_population_size(new_generation, _old_generation, 0), do: new_generation
  defp force_fixed_population_size(new_generation, _old_generation, size_diff) when size_diff < 0 do
    Enum.drop(new_generation, size_diff)
  end
  defp force_fixed_population_size(new_generation, old_generation, size_diff) do
    new_generation ++ Enum.take_random(old_generation, size_diff)
  end
end
