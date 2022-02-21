
##########################################################################################################################

defmodule Homerico.Client do

  def start_link(
    %{gateway: gateway, login: %{user: user, password: password}} = _config,
    init_arg
  ) when
    is_binary(gateway) and
    is_binary(user) and
    is_binary(password) and
    is_list(init_arg)
  do
    try do
      conn = Homerico.Client.Connect.gateway!(gateway)
        |> Homerico.Client.Connect.login!(user, password)
      Agent.start_link fn -> conn end, init_arg
    catch _, reason -> {:error, reason}
    end
  end

  def start_link(_config, init_arg) when is_list(init_arg), do:
    {:error, "invalid configuration"}

  defp apply_callback(false, _), do: :not_implemented
  defp apply_callback(true, {module, fun, args}) do
    try do
      data = apply module, fun, args
      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def callback(module, fun, args) when
    is_atom(fun) and is_list(args),
  do:
    module.__info__(:functions)
      |> Keyword.has_key?(fun)
      |> apply_callback({module, fun, args})

  defmacro __using__(_opts) do
    quote do
      use Agent

      def start_link(init_arg) when is_list(init_arg) do
        try do
          config = case Homerico.Client.callback(__MODULE__, :configuration, []) do
            :not_implemented -> Keyword.fetch!(init_arg, :config)
            {:error, reason} -> throw reason
            {:ok, data} -> data
          end
          Homerico.Client.start_link config, init_arg
        catch _, reason -> {:error, reason}
        end
      end

    end
  end

end

##########################################################################################################################
