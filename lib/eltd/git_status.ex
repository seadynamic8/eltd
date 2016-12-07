defmodule Eltd.GitStatus do

  def set_status(state) do
    status = get_status(state)
    [ current_branch, commit_status ] = parse_status(status)

    state
      |> put_in([:git_status, :full_message], status)
      |> put_in([:git_status, :current_branch], current_branch)
      |> put_in([:git_status, :commit_status], parse_commit_status(commit_status))
  end

  def print_status(%{app: app} = state) do
    IO.puts "\n#{app}: Git status"
    IO.puts "------------------------"
    IO.puts get_in(state, [:git_status, :full_message])
    IO.puts "------------------------"
  end

  defp get_status(%{app: app}) do
    { _, status } = Eltd.Command.git ["status"], app
    status
  end

  defp parse_status(git_status) do
    [ "On branch " <> current_branch | rest_of_status ] =
      String.split(status, "\n")

    commit_status = find_commit_status(rest_of_status)

    [ current_branch, commit_status ]
  end

  defp find_commit_status([ "Your branch" <> _, 
                             "  (use" <> _,
                             commit_status | _rest ]), do: commit_status
  defp find_commit_status([ "Your branch" <> _,
                             commit_status | _rest ]), do: commit_status
  defp find_commit_status([ commit_status | _rest ]), do: commit_status

  defp parse_commit_status(commit_status) do
    case commit_status do
      "nothing to commit, working directory clean" -> :clean
      "Changes to be committed:" ->                   :staged
      "Changes not staged for commit:" ->             :unstaged
      "Untracked files:" ->                           :unstaged
      _ ->                                            :unexpected
    end
  end

end