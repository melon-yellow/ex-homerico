
defmodule Homerico.Connect.Config do
  defstruct [
    :address,
    host: "127.0.0.1",
    port: 8080,
    token: "",
    menus: []
  ]
end

defmodule Homerico.Connect do
  @moduledoc """
  Documentation for `Homerico.Connect`.
  """

  @expire_date ~D[2022-6-1]

  @config %Homerico.Connect.Config{
    address: &"#{@config.host}:#{@config.port}"
  }

  @doc """
  Homerico W3 Handshake Verification.
  """
  defp handshake(ref) when is_binary(key) do
    try do
      # Request URL
      url = "http://homerico.com.br/linkautenticacao.asp?empresa=#{ref}"

      # Do Request
      data = case HTTPoison.get(url) do
        {:ok, %{status_code: 200, body: body}} -> Poison.decode!(body)
        {:ok, %{status_code: 404}} -> throw "could not reach the link"
        {:error, %{reason: reason}} -> throw reason
      end

      # Check Response
      unless Map.has_key?(data, :ip) and is_binary(data.ip) do
        throw "response key 'ip' not valid"
      end
      unless Map.has_key?(data, :porta) and is_binary(data.porta) do
        throw "response key 'porta' not valid"
      end

      # Set Parameters
      Map.merge(@config, %{
        host: data.ip,
        port: String.to_integer(data.porta)
      })

      {:ok, @config}
    catch
      reason -> {:error, reason}
    end
  end

  @doc """
  Homerico Local Login.
  """
  def login(user, password) when is_binary(user) and is_binary(password) do
    try do
      # Request URL
      url = "http://#{@config.address.}/login.asp?"

      # Request XML
      now = DateTime.utc_now
      html = EEx.eval_file("login.html", %{
        user: user,
        password: password
        date: "#{now.year}-#{now.month}-#{now.day}",
      })

      # Do Request
      data = case HTTPoison.post(url, Base.encode16(html)) do
        {:ok, %{status_code: 200, body: body}} -> Poison.decode!(body)
        {:ok, %{status_code: 404}} -> throw "could not reach the link"
        {:error, %{reason: reason}} -> throw reason
      end

      # Check Response
      unless Map.has_key?(data, :status) and is_binary(data.status) do
        throw "response key 'status' not valid"
      end
      # Check Login Status
      unless data.status === "1" do
        throw "not accepted by the server"
      end
      unless Map.has_key?(data, :autenticacao) and is_binary(data.autenticacao) do
        throw "response key 'autenticacao' not valid"
      end
      unless Map.has_key?(data, :menu) and is_binary(data.menu) do
        throw "response key 'menu' not valid"
      end

      # Set Parameters
      Map.merge(@config, %{
        token: data.autenticacao,
        menus: String.split(data.menu, ",")
      })

      {:ok, @config}
    catch
      reason -> {:error, reason}
    end
  end
end
