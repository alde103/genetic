defmodule Utilities.Statistics do
  use GenServer
  def init(opts) do
    :ets.new(:statistics, [:set, :public, :named_table])
    {:ok, opts}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def insert(generation, statistics), do: :ets.insert(:statistics, {generation, statistics})

  def lookup(generation), do: hd(:ets.lookup(:statistics, generation))
end
