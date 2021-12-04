defmodule Electral do
  @moduledoc """
  Documentation for `Electral`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Electral.hello()
      :world

  """
  def hello(), do: "hello"
  def hello(""), do: "hello"
  def hello(name), do: "who is " <> name <> "?"
end
