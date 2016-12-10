defmodule Eltd.GitCommit do

  alias Eltd.Command

  def add_and_commit_changes(%{app: app} = state) do
    IO.puts "-> Adding changes."
    Command.git ["add", "."], app
    commit_changes(state)
  end

  def commit_changes(%{app: app}) do
    IO.puts "-> Commiting changes as 'temp commit'"
    Command.git ["commit", "-m", "temp commit"], app
  end

  def prompt_user_to_commit? do
    response = IO.gets "Do you want to commit changes [y/n]: "
    response = response |> String.trim |> String.downcase

    case response do
      "y" -> true
      "n" ->
        IO.puts "-> Nothing changed."
        false
      response ->
        IO.puts "Invalid choice: #{response} - Only 'y' or 'n' is allowed!"
        prompt_user_to_commit?
    end
  end

end