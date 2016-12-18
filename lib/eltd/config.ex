defmodule Eltd.Config do

  @default_apps Application.get_env(:eltd, :default_apps)

  def get_apps(custom_apps) do
    if custom_apps == [] do
      case read_config(:default_apps) do
        :not_set -> @default_apps
        list -> list
      end
    else
      custom_apps
    end
  end

  def working_directory do
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

end