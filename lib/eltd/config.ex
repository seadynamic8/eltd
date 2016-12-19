defmodule Eltd.Config do

  @default_apps Application.get_env(:eltd, :default_apps)
  @commit_message Application.get_env(:eltd, :commit_message)

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

  def commit_message do
    case read_config(:commit_message) do
      :not_set -> @commit_message
      message -> message
    end
  end

  defp read_config(key) do
    try do
      case Mix.Config.read!(config_file) do
        [eltd: config] -> parse_app_config(config[key])
        [] -> :not_set
      end
    catch
      :error, _ -> :not_set
    end
  end

  def parse_app_config(app_config) do
    case app_config do
      nil -> :not_set
      value -> value
    end
  end

  defp config_file do
    Application.get_env(:eltd, :user_config_file) |> Path.expand
  end

end
