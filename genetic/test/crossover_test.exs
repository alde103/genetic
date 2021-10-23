defmodule CrossoverTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Types.Chromosome

  property "single_point/3 maintains the size of input chromosomes" do
    check all size <- integer(0..100),
              gene_1 <- list_of(integer(), length: size),
              gene_2 <- list_of(integer(), length: size) do
      p1 = %Chromosome{genes: gene_1, size: size}
      p2 = %Chromosome{genes: gene_2, size: size}
      {c1, c2} = Toolbox.Crossover.single_point(p1, p2, 1)
      assert c1.size == size and c2.size == size
    end
  end
end
