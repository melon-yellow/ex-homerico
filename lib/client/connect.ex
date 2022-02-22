
##########################################################################################################################

defmodule Homerico.Client.Connection do
  defstruct [
    host: "127.0.0.1",
    port: 80,
    token: "",
    menus: []
  ]
end

##########################################################################################################################

defmodule Homerico.Client.Connect do
  use Unsafe.Generator, handler: {Unsafe.Handler, :bang!}
  alias Homerico.Client.Connection
  alias Homerico.Client.HTTP

  @unsafe [gateway: 1, login: 3]

  defp set_conn!(origin) when is_map(origin), do:
    Map.merge %Connection{}, origin
  defp set_conn!(origin, base) when is_map(origin) and is_map(base), do:
    Map.merge(base, origin) |> set_conn!

  defp get_gateway!(server), do: %Connection{host: "homerico.com.br"}
    |> HTTP.get!("linkautenticacao.asp?empresa=#{server}")
    |> Poison.decode!

  defp extract_gateway!(%{"ip" => host, "porta" => port})
    when is_binary(host) and is_binary(port), do:
      %{host: host, port: String.to_integer(port)}
  defp extract_gateway!(_), do: throw "invalid response from server"

  def gateway(server) when is_binary(server) do
    try do
      # Get Partial conn
      conn = server
        |> get_gateway!
        |> extract_gateway!
        |> set_conn!

      {:ok, conn}
    catch _, reason -> {:error, reason}
    end
  end

  defp set_params!({user, password}), do: [
    user: user,
    password: password,
    date: Homerico.date_format!
  ]

  defp set_request_html!(params), do: :homerico
    |> Application.app_dir("priv/connect/login.heex")
    |> EEx.eval_file(params)
    |> String.replace(~r/\s/, "")

  defp get_token!(html, conn), do: conn
    |> HTTP.post16!("login.asp?", html)
    |> Poison.decode!

  defp extract_token!(%{"menu" => menus, "autenticacao" => token, "status" => sts})
    when is_binary(menus) and is_binary(token) and (sts == "1"), do:
      %{token: token, menus: String.split(menus, ",")}
  defp extract_token!(_), do: throw "invalid response from server"

  def login(%Connection{} = conn, user, password)
    when is_binary(user) and is_binary(password) do
    try do
      # Get Login Token
      update = {user, password}
        |> set_params!
        |> set_request_html!
        |> get_token!(conn)
        |> extract_token!
        |> set_conn!(conn)

      {:ok, update}
    catch _, reason -> {:error, reason}
    end
  end

end

##########################################################################################################################
