
##########################################################################################################################

defmodule Homerico.Client.Config do
  defmodule Login, do: defstruct [user: "", password: ""]
  defstruct [gateway: "", login: %Login{}]
end

##########################################################################################################################

defmodule Homerico.Client do
  require Agent
  alias Homerico.Client.Callback

  @callback configuration() :: any
  @optional_callbacks [configuration: 0]

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

  defmacro __using__(opts) when is_list(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use Agent, Keyword.drop(opts, [:configuration])

      @behaviour Homerico.Client
      @mix_env Mix.env()

      alias __MODULE__

      def start_link(init_arg) when is_list(init_arg) do
        try do
          config = case Callback.apply(__MODULE__, :configuration, []) do
            :not_implemented -> Keyword.fetch!(opts, :configuration)
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

defmodule Homerico.Client.Callback do

  defp implement(false, _), do: :not_implemented
  defp implement(true, {module, fun, args}) do
    try do
      data = apply module, fun, args
      {:ok, data}
    catch _, reason -> {:error, reason}
    end
  end

  def apply(module, fun, args) when
    is_atom(fun) and is_list(args),
  do:
    module.__info__(:functions)
      |> Keyword.has_key?(fun)
      |> implement({module, fun, args})

end

##########################################################################################################################
