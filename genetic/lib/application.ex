defmodule Genetic.Application do
  use Application
  def start(_type, _args) do
    children = [
      {Utilities.Statistics, []},
      {Utilities.Genealogy, []},
    ]
    opts = [strategy: :one_for_one, name: Genetic.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
