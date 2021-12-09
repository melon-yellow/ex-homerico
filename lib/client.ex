
import Unsafe.Handler

defmodule Homerico.Client do
  use Unsafe.Generator,
    handler: :bang!

  @unsafe [
    get: 2,
    post16: 3
  ]

  defp handle_http!({:ok, %{status_code: 200, body: body}}), do: Poison.decode!(body)
  defp handle_http!({:ok, %{status_code: 404}}), do: throw "(404) could not reach the link"
  defp handle_http!({:error, %{reason: reason}}), do: throw reason

  defp base_url!(
    %Homerico.Connect.Config{} = config
  ), do: "http://#{config.host}:#{config.port}/"

  def get(
    %Homerico.Connect.Config{} = config,
    url
  ) when is_binary(url) do
    try do
      Homerico.check_expire_date!

      data = HTTPoison.get(
        (config |> base_url!) <> url
      ) |> handle_http!

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
    is_binary(stream)
  do
    try do
      Homerico.check_expire_date!

      data = HTTPoison.post(
        (config |> base_url!) <> url,
        (stream |> Base.encode16)
      ) |> handle_http!

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

end
