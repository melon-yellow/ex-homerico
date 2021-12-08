
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
    { :gateway, 1 },
    { :login, 3 }
  ]

  def gateway(server) when is_binary(server) do
    try do
      Homerico.check_expire_date!

      # Do Request
      data = %Homerico.Connect.Config{ host: "homerico.com.br" }
        |> Homerico.Client.get!("linkautenticacao.asp?empresa=#{server}")

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

  def login(
    %Homerico.Connect.Config{} = config,
    user,
    password
  ) when
    is_binary(user) and
    is_binary(password)
  do
    try do
      Homerico.check_expire_date!

      # Path to Login HTML
      login_file = Application.app_dir(
        :homerico,
        "static/login.html"
      )

      # Format HTML
      html = EEx.eval_file(login_file, [
        user: user,
        password: password,
        date: Homerico.date_format!
      ])

      # Do Request
      data = config |> Homerico.Client.post16!("login.asp?", html)

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
      Map.merge(config, %{
        menus: String.split(data["menu"], ","),
        token: data["autenticacao"]
      })

      {:ok, config}
    catch
      reason -> {:error, reason}
    end
  end

end
