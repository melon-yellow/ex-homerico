
import Unsafe.Handler

defmodule Homerico.Reports do
  use Unsafe.Generator,
    handler: :bang!

  @unsafe [
    { :relatorio_lista, 4 }
  ]

  defp url_token!(
    numencypt,
    %Homerico.Connect.Config{} = config
  ) when is_binary(numencypt) do
    "numencypt=" <>
    numencypt <>
    "&autenticacao=" <>
    config.token
  end

  def relatorio_lista(
    %Homerico.Connect.Config{} = config,
    dataInicial,
    dataFinal,
    idProcesso
  ) when
    is_binary(dataInicial) and
    is_binary(dataFinal) and
    is_binary(idProcesso) and
    is_binary(config.token)
  do
    try do
      # Check Authentication
      unless Enum.any?(config.menus, &("d1" == &1)) do
        throw "sem acesso ao menu"
      end

      # Set Resquest JSON
      json = %{
        reportselect: "relatoriolistas",
        datainicial: dataInicial,
        datafinal: dataFinal,
        idprocesso: idProcesso
      }

      # Set Request Token
      query = Homerico.Connect.date!
        |> url_token!(config)

      # Set Request URL
      url = "reports/relatoriolistas?#{query}"

      # Do Request
      data = config |> Homerico.Client.post16!(url, json)

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end
end
