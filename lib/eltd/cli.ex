defmodule Eltd.CLI do
  @moduledoc """
    These are command-line ultilities to manage concurrent app workflows.
  """

  alias Eltd.Config
  alias Eltd.GitHandler
  alias Eltd.Command

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches:
                                      [ help: :boolean,
                                        message: :string,
                                        apps: :string
                                      ],
                                     aliases:
                                      [ h: :help,
                                        m: :message,
                                        a: :apps
                                      ])
    case parse do
      { [ help: true ], _, _ }        -> :help
      { _, [ "checkout", branch ], _} -> { :checkout, branch }
      { _, [ "co", branch ], _}       -> { :checkout, branch }
      { _, [ "execute", command ], _} -> { :execute, command }
      { _, [ "e", command ], _}       -> { :execute, command }
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: eltd [checkout | co] <branch>          # Checkout branch concurrently across apps
           eltd [execute | e] "<command string>"  # Execute command concurrently across apps
    """
  end

  def process({ :checkout, branch }) do
    working_directory = Config.get_or_set_working_directory

    Config.apps
    |> Enum.map(fn app ->
        Task.async(fn -> GitHandler.process(app, branch) end)
      end)
    |> Enum.map(&(Task.await(&1, 500000)))
    |> Enum.each(&GitHandler.process_after/1)

    IO.puts "\nFinished! :)"

    return_to_original_directory(working_directory)
  end

  def process({ :execute, command_str }) do
    working_directory = Config.get_or_set_working_directory

    [ command | args ] = command_str |> String.split

    Config.apps
    |> Enum.map(fn app ->
        Task.async(fn -> Command.execute(command, args, app) end)
      end)
    |> Enum.map(&(Task.await(&1, 500000)))
    |> Enum.each(fn { app, message } ->
        IO.puts "#{app}: "
        IO.write message
    end)

    IO.puts "\nFinished! :)"

    return_to_original_directory(working_directory)
  end

  def return_to_original_directory(directory), do: File.cd directory

end
