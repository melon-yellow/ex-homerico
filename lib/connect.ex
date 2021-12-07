
import Poison
import HTTPoison

defmodule Homerico.Connect.Config do
  @moduledoc """
  Documentation for `Homerico.Connect.Config`.
  """
  defstruct [
    host: "127.0.0.1",
    port: 8080,
    token: "",
    menus: []
  ]

  @doc """
  Homerico Config get Token-Args.
  """
  def tokenargs!(
    %Homerico.Connect.Config{} = config,
    numencypt
  ) when is_binary(numencypt) do
    "autenticacao=" <>
    config.token <>
    "&numencypt=" <>
    numencypt
  end
end

defmodule Homerico.Connect do
  @moduledoc """
  Documentation for `Homerico.Connect`.
  """

  @expire_date ~D[2022-06-01]

  @doc """
  Formated Date.
  """
  def date!() do
    now = DateTime.utc_now
    "#{now.year}-#{now.month}-#{now.day}"
  end

  @doc """
  Homerico W3 Handshake Verification.
  """
  def gateway!(server) when is_binary(server) do
    case gateway(server) do
      {:error, reason} -> raise reason
      {:ok, config} -> config
    end
  end

  @doc """
  Homerico W3 Handshake Verification.
  """
  def gateway(server) when is_binary(server) do
    try do
      # Request URL
      url = "http://homerico.com.br/linkautenticacao.asp?empresa=#{server}"

      # Do Request
      data = case HTTPoison.get(url) do
        {:ok, %{status_code: 200, body: body}} -> Poison.decode!(body)
        {:ok, %{status_code: 404}} -> throw "could not reach the link"
        {:error, %{reason: reason}} -> throw reason
      end

      # Check Response
      unless Map.has_key?(data, "ip") and is_binary(data["ip"]) do
        throw "response key 'ip' not valid"
      end
      unless Map.has_key?(data, "porta") and is_binary(data["porta"]) do
        throw "response key 'porta' not valid"
      end

      # Set Parameters
      config = %Homerico.Connect.Config{
        port: String.to_integer(data["porta"]),
        host: data["ip"]
      }

      {:ok, config}
    catch
      reason -> {:error, reason}
    end
  end

  @doc """
  Homerico Local Login.
  """
  def login!(
    %Homerico.Connect.Config{} = config,
    user,
    password
  ) when is_binary(user) and is_binary(password) do
    case login(config, user, password) do
      {:error, reason} -> raise reason
      {:ok, config} -> config
    end
  end

  @doc """
  Homerico Local Login.
  """
  def login(
    %Homerico.Connect.Config{} = config,
    user,
    password
  ) when is_binary(user) and is_binary(password) do
    try do
      # Request URL
      url = "http://#{config.host}:#{config.port}/login.asp?"

      # Helpers for HTML
      login_file = Application.app_dir(
        :homerico,
        "static/login.html"
      )

      # Format HTML
      html = Homerico.Connect.date!
        |> &EEx.eval_file(login_file, [
          password: password,
          user: user,
          date: &1
        ])

      # Do Request
      data = Homerico.Get.post16!(url, html)

      # Check Response
      unless Map.has_key?(data, "status") and is_binary(data["status"]) do
        throw "response key 'status' not valid"
      end
      unless data["status"] === "1" do
        throw "not accepted by the server"
      end
      unless Map.has_key?(data, "autenticacao") and is_binary(data["autenticacao"]) do
        throw "response key 'autenticacao' not valid"
      end
      unless Map.has_key?(data, "menu") and is_binary(data["menu"]) do
        throw "response key 'menu' not valid"
      end

      # Set Parameters
      config = Map.merge(config, %{
        menus: String.split(data["menu"], ","),
        token: data["autenticacao"]
      })

      {:ok, config}
    catch
      reason -> {:error, reason}
    end
  end
end
