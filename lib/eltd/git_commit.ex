defmodule Eltd.GitCommit do

  alias Eltd.Command
  alias Eltd.Config

  def add_and_commit_changes(%{app: app} = state) do
    IO.puts "-> Adding changes."
    Command.git ["add", "."], app
    commit_changes(state)
  end

  def commit_changes(%{app: app}) do
    commit_msg = Config.commit_message
    IO.puts "-> Commiting changes as '#{commit_msg}'"
    Command.git ["commit", "-m", commit_msg], app
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