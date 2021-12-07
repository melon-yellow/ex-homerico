
defmodule Homerico.Reports do

  defp httptoken!(
    numencypt,
    %Homerico.Connect.Config{} = config
  ) when is_binary(numencypt) do
    "numencypt=" <>
    numencypt <>
    "&autenticacao=" <>
    config.token
  end

  def relatorioLista(
    %Homerico.Connect.Config{} = config,
    dataInicial,
    dataFinal,
    idProcesso
  ) when is_binary(dataInicial) and is_binary(dataFinal) and is_binary(idProcesso) do
    try do
      # Check Authentication
      unless is_binary(config.token) throw "sem autenticacao"
      unless Enum.any?(config.menus, &("d1" == &1)) throw "sem acesso ao menu"

      # Set Resquest JSON
      json = %{
        reportselect: "relatoriolistas",
        datainicial: dataInicial,
        datafinal: dataFinal,
        idprocesso: idProcesso
      }

      # Set Request Token
      query = Homerico.Connect.date!
        |> httptoken!(config)

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
