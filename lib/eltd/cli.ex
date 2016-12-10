defmodule Eltd.CLI do
  @moduledoc """
    These are command-line ultilities to manage concurrent app workflows.

    Right now, this is setup so that it assumes that you all the @default_apps
    in the same directory level.  Also that you run this program from one of
    those directories.
  """

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
    # System.halt(0)
  end

  def process({ :checkout, branch }) do
    working_directory = get_or_set_working_directory

    apps
    |> Enum.map(fn app ->
        Task.async(fn -> GitHandler.process(app, branch) end)
      end)
    |> Enum.map(&(Task.await(&1, 500000)))
    |> Enum.each(&GitHandler.process_after/1)

    IO.puts "\nFinished! :)"

    return_to_original_directory(working_directory)
  end

  def process({ :execute, command_str }) do
    working_directory = get_or_set_working_directory

    [ command | args ] = command_str |> String.split

    apps
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

  defp get_or_set_working_directory do
    case working_directory_set_in_config do
      :not_set ->
        get_current_directory
      working_directory ->
        IO.puts "Changing directory to config + first app: #{working_directory}"
        File.cd! working_directory
        working_directory
    end
  end

  def working_directory_set_in_config do
    case read_config(:top_level_directory) do
      nil -> 
        IO.puts "not set"
        :not_set
      config_value ->
        Path.expand(config_value) <> "/" <> List.first(apps)
    end
  end

  def read_config(key) do
    case Mix.Config.read!(config_file) do
      [eltd: config] -> config[key]
      [] -> nil
    end
  end

  def config_file do
    config_dir = Application.get_env(:eltd, :config_dir)
    Path.expand("#{config_dir}/config.exs")
  end

  def apps do
    case read_config(:default_apps) do
      nil -> Application.get_env(:eltd, :default_apps)
      list -> list
    end
  end

  defp get_current_directory, do: File.cwd!

  defp return_to_original_directory(directory), do: File.cd directory

end
