import Unsafe.Handler

defmodule Homerico.Client do
  use Unsafe.Generator,
    handler: :bang!

  @unsafe [
    get: 2,
    post16: 3
  ]

  defp handle_data!(body) do
    try do Poison.decode!(body)
    catch _, _ -> body
    end
  end

  defp handle_http!({:ok, %{status_code: 200, body: body}}), do: handle_data!(body)
  defp handle_http!({:ok, %{status_code: 404}}), do: throw "(404) could not reach the link"
  defp handle_http!({:error, %{reason: reason}}), do: throw reason

  defp base_url!(%Homerico.Connect.Config{} = config), do:
    "http://#{config.host}:#{config.port}/"

  def post16(%Homerico.Connect.Config{} = config, url, stream)
    when is_binary(url) and is_map(stream), do:
      post16 config, url, Poison.encode!(stream)

  def post16(%Homerico.Connect.Config{} = config, url, stream)
  when is_binary(url) and is_binary(stream) do
    try do
      Homerico.check_expired!

      data = (base_url! config) <> url
        |> HTTPoison.post(Base.encode16 stream)
        |> handle_http!

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def get(%Homerico.Connect.Config{} = config, url)
  when is_binary(url) do
    try do
      Homerico.check_expired!

      data = (base_url! config) <> url
        |> HTTPoison.get
        |> handle_http!

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

end
