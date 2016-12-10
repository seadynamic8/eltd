defmodule Eltd.GitBranch do

  alias Eltd.Command

  def current_branch?(%{target_branch: target_branch, 
      git_status: %{current_branch: current_branch}}) do
    target_branch == current_branch
  end

  def checkout_or_create_branch(%{app: app, target_branch: branch} = state) do
    args = case branch_exists?(state) do
      true ->  [ "#{branch}" ]
      false -> [ "-b", "#{branch}" ]  # Create new branch
    end

    { _, message } = Command.git [ "checkout" | args ], app
    IO.puts "#{app}: #{String.trim(message)}"
  end

  def branch_exists?(%{app: app, target_branch: branch}) do
    { _, branches_str } = Command.git ["branch"], app
    String.contains?(branches_str, branch)
  end

end