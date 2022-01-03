import Unsafe.Handler

defmodule Homerico.Connect.Config do
  defstruct [
    host: "127.0.0.1",
    port: 80,
    token: "",
    menus: []
  ]
end

defmodule Homerico.Connect do
  use Unsafe.Generator,
    handler: :bang!

  @unsafe [
    gateway: 1,
    login: 3
  ]

  defp set_config!(origin) when is_map(origin), do:
    Map.merge %Homerico.Connect.Config{}, origin
  defp set_config!(origin, base) when is_map(origin) and is_map(base), do:
    Map.merge(base, origin) |> set_config!

  defp get_gateway!(server), do:
    %Homerico.Connect.Config{host: "homerico.com.br"}
      |> Homerico.Client.get!("linkautenticacao.asp?empresa=#{server}")

  defp extract_gateway!(%{"ip" => host, "porta" => port})
    when is_binary(host) and is_binary(port), do:
      %{host: host, port: String.to_integer(port)}
  defp extract_gateway!(_), do: throw "invalid response from server"

  def gateway(server) when is_binary(server) do
    try do
      # Get Partial Config
      config = server
        |> get_gateway!
        |> extract_gateway!
        |> set_config!

      {:ok, config}
    rescue reason -> {:error, reason}
    catch reason -> {:error, reason}
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

  defp get_token!(html, config), do:
    config |> Homerico.Client.post16!("login.asp?", html)

  defp extract_token!(%{"menu" => menus, "autenticacao" => token, "status" => sts})
    when is_binary(menus) and is_binary(token) and (sts == "1"), do:
      %{token: token, menus: String.split(menus, ",")}
  defp extract_token!(_), do: throw "invalid response from server"

  def login(%Homerico.Connect.Config{} = config, user, password)
    when is_binary(user) and is_binary(password) do
    try do
      # Get Login Token
      hydrated = {user, password}
        |> set_params!
        |> set_request_html!
        |> get_token!(config)
        |> extract_token!
        |> set_config!(config)

      {:ok, hydrated}
    rescue reason -> {:error, reason}
    catch reason -> {:error, reason}
    end
  end

end
