
defmodule Homerico do

  @expire_date ~D[2022-06-01]

  def check_expire_date!() do
    if DateTime.now!("Etc/UTC") |> Date.diff(@expire_date) >= 0 do
      throw "module expired"
    end
  end

  def date_format!() do
    now = DateTime.utc_now
    "#{now.year}-#{now.month}-#{now.day}"
  end

end
