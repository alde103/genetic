population_size = 2
bitstring_length = 50
desired = 50

# Book example
# population_size = 50
# bitstring_length = 1000
# desired = 1000

initial_population =
  for _ <- 1..population_size, do: for(_ <- 1..bitstring_length, do: Enum.random(0..1))

evaluate = fn population -> Enum.sort_by(population, &Enum.sum/1, &Kernel.>=/2) end

selection = fn population ->
  population
  |> Enum.chunk_every(2)
  |> Enum.map(&List.to_tuple(&1))
end

crossover = fn population ->
  Enum.reduce(population, [], fn {p1, p2}, acc ->
    cx_point = :rand.uniform(bitstring_length)
    {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
    [h1 ++ t2, h2 ++ t1 | acc]
  end)
end

mutation = fn population ->
  population
  |> Enum.map(fn chromosome ->
    if :rand.uniform() < 0.05 do
      Enum.shuffle(chromosome)
    else
      chromosome
    end
  end)
end

algorithm = fn population, algorithm ->
  best = Enum.max_by(population, &Enum.sum/1)
  IO.puts("\rCurrent Best: #{inspect(Enum.sum(best))}")

  if Enum.sum(best) >= desired do
    best
  else
    population
    |> evaluate.()
    |> selection.()
    |> crossover.()
    |> mutation.()
    |> algorithm.(algorithm)
  end
end

solution = algorithm.(initial_population, algorithm)
IO.write("\n Answer is \n")
IO.inspect(solution)
