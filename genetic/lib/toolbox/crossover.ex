defmodule Toolbox.Crossover do
  alias Types.Chromosome
  # for Permutation problems.
  def order_one(p1, p2, _rate) do
    lim = Enum.count(p1.genes) - 1
    # Get random range
    {i1, i2} =
      [:rand.uniform(lim), :rand.uniform(lim)]
      |> Enum.sort()
      |> List.to_tuple()

    # p2 contribution
    slice1 = Enum.slice(p1.genes, i1..i2)
    slice1_set = MapSet.new(slice1)
    p2_contrib = Enum.reject(p2.genes, &MapSet.member?(slice1_set, &1))
    {head1, tail1} = Enum.split(p2_contrib, i1)

    # p1 contribution
    slice2 = Enum.slice(p2.genes, i1..i2)
    slice2_set = MapSet.new(slice2)
    p1_contrib = Enum.reject(p1.genes, &MapSet.member?(slice2_set, &1))
    {head2, tail2} = Enum.split(p1_contrib, i1)

    # Make and return
    {c1, c2} = {head1 ++ slice1 ++ tail1, head2 ++ slice2 ++ tail2}

    {%Chromosome{p1 | genes: c1, size: p1.size}, %Chromosome{p2 | genes: c2, size: p2.size}}
  end

  def uniform(p1, p2, rate) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < rate do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()
    {%Chromosome{p1 | genes: c1, size: length(c1)}, %Chromosome{p2 | genes: c2, size: length(c2)}}
  end

  def single_point(p1, p2, _rate) do
    cx_point = :rand.uniform(p1.size)
    {p1_head, p1_tail} = Enum.split(p1.genes, cx_point)
    {p2_head, p2_tail} = Enum.split(p2.genes, cx_point)
    {c1, c2} = {p1_head ++ p2_tail, p2_head ++ p1_tail}
    {%Chromosome{p1 | genes: c1, size: length(c1)}, %Chromosome{p2 | genes: c2, size: length(c2)}}
  end

  def whole_arithmetic_crossover(p1, p2, rate) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(
        fn {x, y} ->
          {
            x*rate + y*(1-rate),
            y*rate + x*(1-rate)
          }
        end
      )
      |> Enum.unzip()

    {%Chromosome{p1 | genes: c1, size: length(c1)}, %Chromosome{p2 | genes: c2, size: length(c2)}}
  end

  def random_rate_whole_arithmetic_crossover(p1, p2, _rate) do
    random_rate = :rand.uniform()
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(
        fn {x, y} ->
          {
            x*random_rate + y*(1-random_rate),
            y*random_rate + x*(1-random_rate)
          }
        end
      )
      |> Enum.unzip()

    {%Chromosome{p1 | genes: c1, size: length(c1)}, %Chromosome{p2 | genes: c2, size: length(c2)}}
  end

end
