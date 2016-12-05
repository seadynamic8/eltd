defmodule Eltd.GitHandler do

  alias Eltd.Command

  def process(app, branch) do
    state = %{app: app,
              target_branch: branch,
              git_status: 
                %{full_message: "", current_branch: "", commit_status: :clean}
              }

    state
      |> set_git_status
      |> handle_status
  end

  def process_after(%{app: app, git_status: %{commit_status: status}} = state) do
    case status do
      :staged -> handle_uncommited_changes(state)
      :unstaged -> handle_uncommited_changes(state)
      :unexpected ->
        IO.puts "#{app}: Unexpected git status: "
        print_git_status(state)
      _ -> nil
    end
  end

  defp set_git_status(state) do
    git_status = get_status(state)
    [ current_branch, commit_status ] = parse_git_status(git_status)

    state
      |> put_in([:git_status, :full_message], git_status)
      |> put_in([:git_status, :current_branch], current_branch)
      |> put_in([:git_status, :commit_status], parse_commit_status(commit_status))
  end

  defp get_status(%{app: app}) do
    { _, git_status } = Command.git ["status"], app
    git_status
  end

  defp parse_git_status(git_status) do
    [ "On branch " <> current_branch, commit_status | _rest ] = 
        String.split(git_status, "\n")
    
    [ current_branch, commit_status ]
  end

  defp parse_commit_status(commit_status) do
    case commit_status do
      "nothing to commit, working directory clean" -> :clean
      "Changes to be committed:" ->                   :staged
      "Changes not staged for commit:" ->             :unstaged
      "Untracked files:" ->                           :unstaged
      _ ->                                            :unexpected
    end
  end

  defp handle_status(
      %{app: app,
        target_branch: target_branch,
        git_status:
          %{current_branch: current_branch,
            commit_status: commit_status}} = state) do

    if current_branch == target_branch do
      handle_current_branch(state)
    else
      case commit_status do
        :clean -> checkout_or_create_branch(state)
        :staged -> IO.puts "#{app}: Staged uncommited changes"
        :unstaged -> IO.puts "#{app}: Uncommited changes"
      end
      state
    end
  end

  defp handle_current_branch(%{app: app, target_branch: branch} = state) do
    IO.puts "#{app}: #{branch} is the current branch."
    %{ state | git_status: %{ commit_status: :noop }}
  end

  defp checkout_or_create_branch(%{app: app, target_branch: branch} = state) do
    args = case branch_exists?(state) do
      true ->  [ "#{branch}" ]
      false -> [ "-b", "#{branch}" ]  # Create new branch
    end

    { _, message } = Command.git [ "checkout" | args ], app
    IO.puts "#{app}: #{String.trim(message)}"
  end

  defp branch_exists?(%{app: app, target_branch: branch}) do
    { _, branches_str } = Command.git ["branch"], app
    String.contains?(branches_str, branch)
  end

  def handle_uncommited_changes(
      %{ git_status: %{ commit_status: status }} = state) do

    print_git_status(state)

    response = prompt_user_to_commit?

    if response do
      if status == :staged do
        IO.puts "-> Commiting changes as 'temp commit'"
        commit_changes(state)
      else
        add_and_commit_changes(state)
      end

      checkout_or_create_branch(state)
    end
  end

  def print_git_status(%{app: app} = state) do
    IO.puts "\n#{app}: Git status"
    IO.puts "------------------------"
    IO.puts get_in(state, [:git_status, :full_message])
    IO.puts "------------------------"
  end

  defp prompt_user_to_commit? do
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

  defp add_and_commit_changes(%{app: app} = state) do
    IO.puts "-> Adding changes and commiting them as 'temp commit'"
    Command.git ["add", "."], app
    commit_changes(state)
  end

  defp commit_changes(%{app: app}) do
    Command.git ["commit", "-m", "temp commit"], app
  end

end