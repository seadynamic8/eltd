defmodule Eltd.Command do

  def git(args, app) do
    # System.cmd "git", args, cd: cd_dir(app)
    execute("git", args, app)
  end

  def execute(command, args, app) do
    # System.cmd "command", args, get_opts(app)
    %Porcelain.Result{ out: message } = 
      Porcelain.exec command, args, [err: :out] ++ cd_dir(app)
    { app, message }
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

end