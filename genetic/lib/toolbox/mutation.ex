defmodule Toolbox.Mutation do
  alias Types.Chromosome

  # For binary genotypes
  def flip(chromosome, probability) do
    new_genes =
      chromosome.genes
      |> Enum.map(fn g ->
        if :rand.uniform() < probability do
          Bitwise.bxor(g, 1)
        else
          g
        end
      end)

    Chromosome.new(genes: new_genes, size: chromosome.size)
  end

  # For binary, permutation, and some real-value genotypes.
  def scramble(chromosome, _n) do
    new_genes =
      chromosome.genes
      |> Enum.shuffle()

    Chromosome.new(genes: new_genes, size: chromosome.size)
  end

  def scramble_by_slice(chromosome, n) do
    start = :rand.uniform(n - 1)

    {lo, hi} =
      if start + n >= chromosome.size do
        {start - n, start}
      else
        {start, start + n}
      end

    head = Enum.slice(chromosome.genes, 0, lo)
    mid = Enum.slice(chromosome.genes, lo, hi)
    tail = Enum.slice(chromosome.genes, hi, chromosome.size)

    Chromosome.new(genes: head ++ Enum.shuffle(mid) ++ tail, size: chromosome.size)
  end

  def gaussian(chromosome, _arg) do
    mu = Enum.sum(chromosome.genes) / chromosome.size

    sigma =
      chromosome.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(chromosome.size)

    new_genes =
      chromosome.genes
      |> Enum.map(fn _ ->
        :rand.normal(mu, sigma)
      end)

    Chromosome.new(genes: new_genes, size: chromosome.size)
  end
end
