defmodule Eltd.Command do

  def git(args, app) do
    execute("git", args, app)
  end

  def execute(command, args, app) do
    try do
      case Porcelain.exec command, args, [err: :out] ++ cd_dir(app) do
        %Porcelain.Result{ out: message } ->
          { app, message }
        {:error, reason} ->
          IO.puts "Error: The reason code: #{reason}"
          System.halt(9)
        error ->
          IO.puts "Unknown error: #{error}"
          System.halt(0)
      end
    catch
      :error, :eacces ->
        throw "Error: :eacces\n"
          <> "It's likely you didn't set configuration for "
          <> "top_level_directory in ~/.mix/escripts/config.ini or you are not running the "
          <> "program from within the app directories, or there is a "
          <> "permissions issue."
        # System.halt(0)
      what, value ->
        IO.puts "Caught #{inspect what} with #{inspect value}"
        System.halt(0)
    end
  end

  def parse_command(command_str) do
    split_command = command_str |> String.split(" ", parts: 2)

    if has_args?(split_command) do
      [ command | [ rest_of_command ] ] = split_command

      { command, extract_args(rest_of_command) }
    else
      command = split_command |> List.first

      { command, [] }
    end
  end

  defp cd_dir(app) do
    if current_app_dir != app do
      [dir: "../#{app}"] # Change to targeted app directory
    else
      []
    end
  end

  defp current_app_dir do
    System.cwd |> Path.basename
  end

  defp has_args?(split_command) do
    length(split_command) > 1
  end

  defp extract_args(rest_of_command) do
    if String.contains?(rest_of_command, [~s("), ~s(')]) do
      # Assumes only one quoted string at the end
      [ front, string ] = String.split(rest_of_command, ~r("|'), trim: true)
      String.split(front, " ", trim: true) ++ [ string ]
    else
      String.split(rest_of_command, " ", trim: true)
    end
  end

end
