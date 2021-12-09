
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

  defp check_menu!(
    %Homerico.Connect.Config{} = config,
    menu
  ) when is_binary(menu) do
    unless Enum.any?(config.menus, &(menu == &1)) do
      throw "no access to menu '#{menu}'"
    end
  end

  defp http_query!(
    %Homerico.Connect.Config{} = config
  ), do: config |> http_query!(Homerico.date_format!)

  defp http_query!(
    %Homerico.Connect.Config{} = config,
    numencypt
  ) when is_binary(numencypt) do
    "autenticacao=" <>
    config.token <>
    "&numencypt=" <>
    numencypt
  end

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
      # Verify Access
      config |> check_menu!("d1")

      # Set Request Query
      query = config |> http_query!

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/relatoriolistas?#{query}",
        %{
          reportselect: "relatoriolistas",
          idprocesso: id_processo,
          datainicial: data_inicial,
          datafinal: data_final
        }
      )

      {:ok, data}
    catch
      reason -> {:error, reason}
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
      # Verify Access
      config |> check_menu!("d3")

      # Set Request Query
      query = config |> http_query!("[numencypt]")

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/relatoriogerencial?#{query}",
        %{
          registro: registro,
          data: data
        }
      )

      {:ok, data}
    catch
      reason -> {:error, reason}
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
      # Verify Access
      config |> check_menu!("d3")

      # Set Request Query
      query = config |> http_query!

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/relatoriogerencial?#{query}",
        %{
          idreport: id_report,
          data: data
        }
      )

      {:ok, data}
    catch
      reason -> {:error, reason}
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
      # Verify Access
      config |> check_menu!("d1")

      # Set Request Query
      query = config |> http_query!

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/relatorioboletim?#{query}",
        %{
          reportselect: "relatorioboletim",
          idreport: id_report,
          datainicial: data_inicial,
          datafinal: data_final
        }
      )

      {:ok, data}
    catch
      reason -> {:error, reason}
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
      # Verify Access
      config |> check_menu!("pro09")

      # Set Request Query
      query = config |> http_query!

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/producaolistas?#{query}",
        %{
          controle: controle,
          data: data_final
        }
      )

      {:ok, data}
    catch
      reason -> {:error, reason}
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
      # Verify Access
      config |> check_menu!("pro4")

      # Set Request Query
      query = config |> http_query!

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/ov?#{query}",
        %{
          idprocessogrupo: id_processo_grupo,
          data: data
        }
      )

      {:ok, data}
    catch
      reason -> {:error, reason}
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
      # Verify Access
      config |> check_menu!("pro2")

      # Set Request Query
      query = config |> http_query!

      # Do Request
      data = config |> Homerico.Client.post16!(
        "reports/interrupcoes?#{query}",
        %{
          idprocesso: id_processo,
          data: data,
        }
      )

      {:ok, data}
    catch
      reason -> {:error, reason}
    end
  end

end
