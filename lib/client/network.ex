
##########################################################################################################################

defmodule Homerico.Client.HTTP do
  use Unsafe.Generator, handler: {Unsafe.Handler, :bang!}
  alias Homerico.Client.Connection

  @unsafe [get: 2, post16: 3]

  defp base_url!(%Connection{} = conn), do:
    "http://#{conn.host}:#{conn.port}/"

  defp handle_http!({:ok, %{status_code: 200, body: body}}), do: body
  defp handle_http!({:ok, %{status_code: status}}), do: throw "http status: #{status}"
  defp handle_http!({:error, %{reason: reason}}), do: throw reason

  def post16(%Connection{} = conn, url, stream)
    when is_binary(url) and is_map(stream), do:
      post16 conn, url, Poison.encode!(stream)

  def post16(%Connection{} = conn, url, stream)
  when is_binary(url) and is_binary(stream) do
    try do
      Homerico.check_expired!

      data = (base_url! conn) <> url
        |> HTTPoison.post(Base.encode16 stream)
        |> handle_http!

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def get(%Connection{} = conn, url)
  when is_binary(url) do
    try do
      Homerico.check_expired!

      data = (base_url! conn) <> url
        |> HTTPoison.get
        |> handle_http!

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

end

##########################################################################################################################
