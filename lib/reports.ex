
defmodule Homerico.Reports do
  use Unsafe.Generator, handler: {Unsafe.Handler, :bang!}
  alias Homerico.Client.Network
  alias Homerico.Client.Connection

  @unsafe [
    relatorio_lista: 4,
    relatorio_gerencial_registro: 3,
    relatorio_gerencial_report: 3,
    relatorio_boletim: 4,
    producao_lista: 3,
    relatorio_ov: 3,
    relatorio_interrupcoes: 3
  ]

  defp throw_conn!(%Connection{} = conn), do: conn
  defp throw_conn!(_conn), do: throw "invalid client/connection"

  defp get_conn!(pid), do:
    pid |> Agent.get(& &1) |> throw_conn!

  defp throw_menu!(member) when member, do: true
  defp throw_menu!(_), do: throw "no access to menu"

  defp check_menu!(%Connection{} = conn, menu)
    when is_binary(menu), do: conn.menus |> Enum.member?(menu) |> throw_menu!

  defp http_query!(%Connection{} = conn, date \\ Homerico.date_format!)
    when is_binary(date), do: "autenticacao=#{conn.token}&numencypt=#{date}"

  def relatorio_lista(
    pid,
    id_processo,
    data_inicial,
    data_final
  ) when
    is_binary(id_processo) and
    is_binary(data_inicial) and
    is_binary(data_final)
  do
    try do
      conn = get_conn! pid
      check_menu! conn, "d1"

      # Do Request
      data = conn |> Network.post16!(
        "reports/relatoriolistas?" <> http_query!(conn),
        %{
          reportselect: "relatoriolistas",
          idprocesso: id_processo,
          datainicial: data_inicial,
          datafinal: data_final
        }
      )

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def relatorio_gerencial_registro(
    pid,
    registro,
    data
  ) when
    is_binary(registro) and
    is_binary(data)
  do
    try do
      conn = get_conn! pid
      check_menu! conn, "d3"

      # Do Request
      data = conn |> Network.post16!(
        "reports/relatoriogerencial?" <> http_query!(conn, "[numencypt]"),
        %{
          registro: registro,
          data: data
        }
      )

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def relatorio_gerencial_report(
    pid,
    id_report,
    data
  ) when
    is_binary(id_report) and
    is_binary(data)
  do
    try do
      conn = get_conn! pid
      check_menu! conn, "d3"

      # Do Request
      data = conn |> Network.post16!(
        "reports/relatoriogerencial?" <> http_query!(conn),
        %{
          idreport: id_report,
          data: data
        }
      )

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def relatorio_boletim(
    pid,
    id_report,
    data_inicial,
    data_final
  ) when
    is_binary(id_report) and
    is_binary(data_inicial) and
    is_binary(data_final)
  do
    try do
      conn = get_conn! pid
      check_menu! conn, "d1"

      # Do Request
      data = conn |> Network.post16!(
        "reports/relatorioboletim?" <> http_query!(conn),
        %{
          reportselect: "relatorioboletim",
          idreport: id_report,
          datainicial: data_inicial,
          datafinal: data_final
        }
      )

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def producao_lista(
    pid,
    controle,
    data_final
  ) when
    is_binary(controle) and
    is_binary(data_final)
  do
    try do
      conn = get_conn! pid
      check_menu! conn, "pro09"

      # Do Request
      data = conn |> Network.post16!(
        "reports/producaolistas?" <> http_query!(conn),
        %{
          controle: controle,
          data: data_final
        }
      )

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def relatorio_ov(
    pid,
    id_processo_grupo,
    data
  ) when
    is_binary(id_processo_grupo) and
    is_binary(data)
  do
    try do
      conn = get_conn! pid
      check_menu! conn, "pro4"

      # Do Request
      data = conn |> Network.post16!(
        "reports/ov?" <> http_query!(conn),
        %{
          idprocessogrupo: id_processo_grupo,
          data: data
        }
      )

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def relatorio_interrupcoes(
    pid,
    id_processo,
    data
  ) when
    is_binary(id_processo) and
    is_binary(data)
  do
    try do
      conn = get_conn! pid
      check_menu! conn, "pro2"

      # Do Request
      data = conn |> Network.post16!(
        "reports/interrupcoes?" <> http_query!(conn),
        %{
          idprocesso: id_processo,
          data: data,
        }
      )

      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

end
