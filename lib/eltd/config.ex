defmodule Eltd.Config do

  @default_apps Application.get_env(:eltd, :default_apps)

  def get_or_set_working_directory do
    case working_directory_set_in_config do
      :not_set -> get_current_directory
      working_directory ->
        IO.puts "Changing directory to top_level_directory / first app: #{working_directory}"
        File.cd! working_directory
        working_directory
    end
  end

  def apps do
    case read_config(:default_apps) do
      :not_set -> @default_apps
      list -> list
    end
  end

  defp working_directory_set_in_config do
    case read_config(:top_level_directory) do
      :not_set -> :not_set
      top_level_directory ->
        Path.expand(top_level_directory) <> "/" <> List.first(@default_apps)
    end
  end

  defp read_config(key) do
    case Mix.Config.read!(config_file) do
      [eltd: config] -> config[key]
      [] -> :not_set
    end
  end

  defp config_file do
    Application.get_env(:eltd, :user_config_file) |> Path.expand
  end

  defp get_current_directory, do: File.cwd!

end