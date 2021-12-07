
import Poison
import HTTPoison

defmodule Homerico.Get do
  @moduledoc """
  Documentation for `Homerico.Get`.
  """

  @doc """
  HTTP POST HEX Encoded Content.
  """
  def post16!(url, content) when is_binary(url) and is_binary(content) do
    case post16(url, content) do
      {:error, reason} -> raise reason
      {:ok, config} -> config
    end
  end

  @doc """
  HTTP POST HEX Encoded Content.
  """
  def post16(url, content) when is_binary(url) and is_binary(content) do
    try do
      data = case HTTPoison.post(url, Base.encode16(content)) do
        {:ok, %{status_code: 200, body: body}} -> Poison.decode!(body)
        {:ok, %{status_code: 404}} -> throw "(404) could not reach the link"
        {:error, %{reason: reason}} -> throw reason
      end

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end

  @doc """
  Homerico Get Relatorio-Lista.
  """
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

      # Request Token
      tokenargs = Homerico.Connect.date!
        |> &Homerico.Connect.Config.tokenargs!(config, &1)

      # Request URL
      url = "http://#{config.host}:#{config.port}/reports/relatoriolistas?#{tokenargs}"

      # Resquest JSON
      json = %{
        reportselect: "relatoriolistas",
        datainicial: dataInicial,
        datafinal: dataFinal,
        idprocesso: idProcesso
      }

      # Request Server
      data = Poison.encode!(json)
        |> &Homerico.Get.post16!(url, &1)

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end
end
