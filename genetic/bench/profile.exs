defmodule DummyProblem do
  @behavior Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..100, do: Enum.random(0..1)
    Chromosome.new(genes: genes, size: 100)
  end

  @impl true
  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  @impl true
  def terminate?(_poputlation, generation), do: generation == 1
end

defmodule Profiler do
  import ExProf.Macro

  def do_analyze do
    profile do
      Genetic.run(DummyProblem)
    end
  end

  def run do
    {records, _block_result} = do_analyze()
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.inspect "Total = #{total_percent}"
  end
end

Profiler.run()
