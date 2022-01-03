
defmodule Homerico do

  @expire_date Date.to_gregorian_days ~D[2022-06-01]

  defp now!, do: DateTime.now!("Etc/UTC") |> Date.to_gregorian_days

  def check_expired!(date \\ now!())
  def check_expired!(date) when (date - @expire_date) < 0, do: false
  def check_expired!(_), do: throw "module expired"

  def date_format!(now \\ DateTime.utc_now), do:
    "#{now.year}-#{now.month}-#{now.day}"

end
