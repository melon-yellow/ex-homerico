
defmodule Homerico do

  @expire_date ~D[2022-06-01]

  defp throw_expired!(expired) when not expired, do: false
  defp throw_expired!(_), do: throw "client expired"

  def check_expired!(date \\ DateTime.utc_now), do:
    (DateTime.diff(@expire_date, date) <= 0) |> throw_expired!

  def date_format!(date \\ DateTime.utc_now), do:
    "#{date.year}-#{date.month}-#{date.day}"

end
