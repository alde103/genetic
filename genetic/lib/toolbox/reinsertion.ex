defmodule Toolbox.Reinsertion do
  def pure(_parents, offspring, leftovers, _survival_rate), do: offspring ++ leftovers

  def elitist(parents, offspring, leftovers, survival_rate) do
    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)

    survivors =
      old
      |> Enum.sort_by(& &1.fitness, &>=/2)
      |> Enum.take(n)

    offspring ++ survivors
  end

  def uniform(parents, offspring, leftovers, survival_rate) do
    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)
    survivors = Enum.take_random(old, n)
    offspring ++ survivors
  end
end
