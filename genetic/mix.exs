
defmodule Mix.Tasks.Compile.Xor96 do
  use Mix.Task.Compiler

  def run(_args) do
    {result, _errcode} =
      System.cmd(
        "gcc",
        ["-fpic", "-shared", "-o", "xor96.so", "src/xor96.c"],
        stderr_to_stdout: true
      )
    IO.puts(result)
  end
end

defmodule Genetic.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetic,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      compilers: [:xor96] ++ Mix.compilers,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Genetic.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libgraph, "~> 0.13"},
      {:gnuplot, "~> 1.19"},
      {:alex, "~> 0.3.2"},
      {:benchee, "~> 1.0.1"},
      {:exprof, "~> 0.2.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
