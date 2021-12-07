
import Unsafe.Handler

defmodule Homerico.Reports do
  use Unsafe.Generator,
    handler: :bang!

  @unsafe [
    { :relatorio_lista, 4 }
  ]

  defp query_token!(
    numencypt,
    %Homerico.Connect.Config{} = config
  ) when is_binary(numencypt) do
    "numencypt=" <>
    numencypt <>
    "&autenticacao=" <>
    config.token
  end

  defp handle_menu!(
    %Homerico.Connect.Config{} = config,
    menu
  ) when is_binary(menu) do
    unless Enum.any?(config.menus, &(menu == &1)) do
      throw "sem acesso ao menu"
    end
  end

  def relatorio_lista(
    %Homerico.Connect.Config{} = config,
    data_inicial,
    data_final,
    id_processo
  ) when
    is_binary(data_inicial) and
    is_binary(data_final) and
    is_binary(id_processo) and
    is_binary(config.token)
  do
    try do
      # Check Authentication
      config |> handle_menu!("d1")

      # Set Request Token
      query = Homerico.Connect.date!
        |> query_token!(config)

      # Set Request URL
      url = "reports/relatoriolistas?#{query}"

      # Do Request
      data = config |> Homerico.Client.post16!(url, %{
        reportselect: "relatoriolistas",
        datainicial: data_inicial,
        datafinal: data_final,
        idprocesso: id_processo
      })

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end
end
