genotype = fn -> for _ <- 1..1000, do: Enum.random(0..1) end
fitness_function = fn chromosome -> Enum.sum(chromosome) end
max_fitness = 1000

soln = Genetic.run(fitness_function, genotype, max_fitness)

IO.inspect(soln)
