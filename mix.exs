defmodule Eltd.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eltd,
      escript: escript_config,
      version: "0.0.2",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:mix, :logger, :porcelain]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      { :porcelain, "~> 2.0" }
    ]
  end

  defp escript_config do
    [ main_module: Eltd.CLI ]
  end
end
