defmodule Eltd.GitHandler do

  alias Eltd.GitStatus
  alias Eltd.GitBranch
  alias Eltd.GitCommit

  def process(app, branch) do
    state = %{app: app,
              target_branch: branch,
              git_status:
                %{full_message: "", current_branch: "", commit_status: :clean}
              }

    state
      |> GitStatus.set_status
      |> handle_status
  end

  def process_after(%{app: app, git_status: %{commit_status: status}} = state) do
    case status do
      :staged ->   handle_uncommited_changes(state)
      :unstaged -> handle_uncommited_changes(state)
      :unexpected ->
        IO.puts "#{app}: Unexpected git status: "
        GitStatus.print_status(state)
      :current_branch -> nil # No output necessary
      :clean ->          nil # No output necessary
      _ -> IO.puts "#{app}: Error - unexpected after status: #{status}"
    end
  end
  def process_after(other), do:
    raise "Can't call process_after without a state map: #{inspect(other)}"

  defp handle_status(
      %{app: app, git_status: %{commit_status: commit_status}} = state) do

    if GitBranch.current_branch?(state) do
      handle_current_branch(state)
    else
      case commit_status do
        :clean ->    GitBranch.checkout_or_create_branch(state)
        :staged ->   IO.puts "#{app}: Staged uncommited changes"
        :unstaged -> IO.puts "#{app}: Uncommited changes"
        _ -> nil
      end
      state
    end
  end

  defp handle_current_branch(%{app: app, target_branch: branch} = state) do
    IO.puts "#{app}: #{branch} is the current branch."
    %{ state | git_status: %{ commit_status: :current_branch }}
  end

  def handle_uncommited_changes(
      %{ git_status: %{ commit_status: status }} = state) do

    GitStatus.print_status(state)

    response = GitCommit.prompt_user_to_commit?

    if response do
      if status == :staged do
        GitCommit.commit_changes(state)
      else
        GitCommit.add_and_commit_changes(state)
      end

      GitBranch.checkout_or_create_branch(state)
    end
  end

  

end
