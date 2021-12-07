
import Unsafe.Handler

defmodule Homerico.Client do
  use Unsafe.Generator,
    handler: :bang!

  @unsafe [
    { :get, 2 },
    { :post16, 3 }
  ]

  defp handle_http!({:ok, %{status_code: 200, body: body}}), do: Poison.decode!(body)
  defp handle_http!({:ok, %{status_code: 404}}), do: throw "(404) could not reach the link"
  defp handle_http!({:error, %{reason: reason}}), do: throw reason

  def get(
    %Homerico.Connect.Config{} = config,
    url
  ) when is_binary(url) do
    try do
      prefix = "http://#{config.host}:#{config.port}/"

      data = HTTPoison.get(prefix <> url)
        |> handle_http!

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end

  def post16(
    %Homerico.Connect.Config{} = config,
    url,
    stream
  ) when
    is_binary(url) and
    is_map(stream)
  do
    Poison.encode!(stream)
      |> (&post16(config, url, &1)).()
  end

  def post16(
    %Homerico.Connect.Config{} = config,
    url,
    stream
  ) when
    is_binary(url) and
    is_binary(stream)
  do
    try do
      prefix = "http://#{config.host}:#{config.port}/"

      data = Base.encode16(stream)
        |> (&HTTPoison.post(prefix <> url, &1)).()
        |> handle_http!

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end
end
