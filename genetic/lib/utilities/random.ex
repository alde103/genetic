defmodule Utilities.Random do
  @on_load :load_nif

  def load_nif do
    :erlang.load_nif('./xor96', 0)
  end

  def xor96, do: raise "NIF xor96/0 not implemented"
end
