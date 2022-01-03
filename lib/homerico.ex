
defmodule Homerico do

  @expire_date ~D[2022-06-01]

  defp now!, do: DateTime.now! "Etc/UTC"
  defp expire!(date), do: Date.diff date, @expire_date

  def check_expired!(date \\ now!) when expire!(date) < 0, do: false
  def check_expired!(date \\ now!), do: throw "module expired"

  def date_format!(now \\ DateTime.utc_now), do:
    "#{now.year}-#{now.month}-#{now.day}"

end
