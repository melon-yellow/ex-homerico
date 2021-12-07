
import Poison
import HTTPoison

defmodule Homerico.Client do

  @unsafe [
    {:get, 2},
    {:post16, 3}
  ]

  defp handle_response!(request) do
    case request do
      {:ok, %{status_code: 200, body: body}} -> Poison.decode!(body)
      {:ok, %{status_code: 404}} -> throw "(404) could not reach the link"
      {:error, %{reason: reason}} -> throw reason
      other -> throw "wrong type of input"
    end
  end

  def get(
    %Homerico.Connect.Config{} = config,
    url
  ) when is_binary(url) do
    try do
      prefix = "http://#{config.host}:#{config.port}/"

      data = HTTPoison.get(prefix <> url)
        |> handle_response!

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end

  def post16(
    %Homerico.Connect.Config{} = config,
    url,
    stream
  ) when is_binary(url) and is_map(stream) do
    Poison.encode!(stream)
      |> &post16(config, url, &1)
  end

  def post16(
    %Homerico.Connect.Config{} = config,
    url,
    stream
  ) when is_binary(url) and is_binary(stream) do
    try do
      prefix = "http://#{config.host}:#{config.port}/"

      data = Base.encode16(stream)
        |> &HTTPoison.post(prefix <> url, &1)
        |> handle_response!

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end
end
