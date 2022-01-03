import Unsafe.Handler

defmodule Homerico.Reports do
  use Unsafe.Generator,
    handler: :bang!

  @unsafe [
    relatorio_lista: 4,
    relatorio_gerencial_registro: 3,
    relatorio_gerencial_report: 3,
    relatorio_boletim: 4,
    producao_lista: 3,
    relatorio_ov: 3,
    relatorio_interrupcoes: 3
  ]

  defp throw_menu!(valid) when valid, do: true
  defp throw_menu!(_), do: throw "no access to menu"

  defp check_menu!(%Homerico.Connect.Config{} = config, menu)
    when is_binary(menu), do: config.menus |> Enum.member?(menu) |> throw_menu!

  defp http_query!(%Homerico.Connect.Config{} = config, date \\ Homerico.date_format!)
    when is_binary(date), do: "autenticacao=#{config.token}&numencypt=#{date}"

  def relatorio_lista(
    %Homerico.Connect.Config{} = config,
    id_processo,
    data_inicial,
    data_final
  ) when
    is_binary(id_processo) and
    is_binary(data_inicial) and
    is_binary(data_final)
  do
    try do
      check_menu! config, "d1"

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/relatoriolistas?#{http_query! config}",
        %{
          reportselect: "relatoriolistas",
          idprocesso: id_processo,
          datainicial: data_inicial,
          datafinal: data_final
        }
      )

      {:ok, data}
    catch reason -> {:error, reason}
    end
  end

  def relatorio_gerencial_registro(
    %Homerico.Connect.Config{} = config,
    registro,
    data
  ) when
    is_binary(registro) and
    is_binary(data)
  do
    try do
      check_menu! config, "d3"

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/relatoriogerencial?#{http_query! config, '[numencypt]'}",
        %{
          registro: registro,
          data: data
        }
      )

      {:ok, data}
    catch reason -> {:error, reason}
    end
  end

  def relatorio_gerencial_report(
    %Homerico.Connect.Config{} = config,
    id_report,
    data
  ) when
    is_binary(id_report) and
    is_binary(data)
  do
    try do
      check_menu! config, "d3"

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/relatoriogerencial?#{http_query! config}",
        %{
          idreport: id_report,
          data: data
        }
      )

      {:ok, data}
    catch reason -> {:error, reason}
    end
  end

  def relatorio_boletim(
    %Homerico.Connect.Config{} = config,
    id_report,
    data_inicial,
    data_final
  ) when
    is_binary(id_report) and
    is_binary(data_inicial) and
    is_binary(data_final)
  do
    try do
      check_menu! config, "d1"

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/relatorioboletim?#{http_query! config}",
        %{
          reportselect: "relatorioboletim",
          idreport: id_report,
          datainicial: data_inicial,
          datafinal: data_final
        }
      )

      {:ok, data}
    catch reason -> {:error, reason}
    end
  end

  def producao_lista(
    %Homerico.Connect.Config{} = config,
    controle,
    data_final
  ) when
    is_binary(controle) and
    is_binary(data_final)
  do
    try do
      check_menu! config, "pro09"

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/producaolistas?#{http_query! config}",
        %{
          controle: controle,
          data: data_final
        }
      )

      {:ok, data}
    catch reason -> {:error, reason}
    end
  end

  def relatorio_ov(
    %Homerico.Connect.Config{} = config,
    id_processo_grupo,
    data
  ) when
    is_binary(id_processo_grupo) and
    is_binary(data)
  do
    try do
      check_menu! config, "pro4"

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/ov?#{http_query! config}",
        %{
          idprocessogrupo: id_processo_grupo,
          data: data
        }
      )

      {:ok, data}
    catch reason -> {:error, reason}
    end
  end

  def relatorio_interrupcoes(
    %Homerico.Connect.Config{} = config,
    id_processo,
    data
  ) when
    is_binary(id_processo) and
    is_binary(data)
  do
    try do
      check_menu! config, "pro2"

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/interrupcoes?#{http_query! config}",
        %{
          idprocesso: id_processo,
          data: data,
        }
      )

      {:ok, data}
    catch reason -> {:error, reason}
    end
  end

end
