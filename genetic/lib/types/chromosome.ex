defmodule Types.Chromosome do
  @type t :: %__MODULE__{
          genes: Enum.t(),
          id: binary(),
          size: integer(),
          fitness: number(),
          age: integer()
        }

  @enforce_keys :genes

  defstruct [:genes, id: Base.encode16(:crypto.strong_rand_bytes(64)), size: 0, fitness: 0, age: 0]

  def new(opts) do
    id = Base.encode16(:crypto.strong_rand_bytes(64))
    genes = Keyword.fetch!(opts, :genes)
    size = Keyword.get(opts, :size, length(genes))
    age = Keyword.get(opts, :age, 0)
    %Types.Chromosome{genes: genes, id: id, age: age, size: size}
  end
end
