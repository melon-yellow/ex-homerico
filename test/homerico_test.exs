defmodule HomericoTest do
  use ExUnit.Case
  doctest Homerico

  test "greets the world" do
    assert Homerico.Connect.@config == %{
      host: "127.0.0.1",
      port: 8080,
      token: "",
      menus: []
    }
  end
end
