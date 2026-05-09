defmodule Saturn.Fuel do
  @moduledoc """
  A module to calculate needed fuel.

  formula for landing: mass * gravity * 0.033 - 42
  formula for launch: mass * gravity * 0.042 - 33

  all results are rounded down to nearest integer

  because fuel also has weight, to calculate total fuel needed for a trip
  calculation needs to continue until result is <= 0
  """

  @landing_mult "0.033"
  @landing_sub "42"
  @launch_mult "0.042"
  @launch_sub "33"

  @spec calculate_total_fuel_for_launch(Decimal.t(), Decimal.t()) :: Decimal.t()
  def calculate_total_fuel_for_launch(mass, gravity) do
    calculate_total_fuel(mass, gravity, &calculate_fuel_for_launch/2)
  end

  @spec calculate_total_fuel_for_landing(Decimal.t(), Decimal.t()) :: Decimal.t()
  def calculate_total_fuel_for_landing(mass, gravity) do
    calculate_total_fuel(mass, gravity, &calculate_fuel_for_landing/2)
  end

  defp calculate_total_fuel(mass, gravity, calculation_func) do
    required_fuel = calculation_func.(mass, gravity)

    if Decimal.lte?(required_fuel, Decimal.new("0")) do
      Decimal.new("0")
    else
      Decimal.add(calculate_total_fuel(required_fuel, gravity, calculation_func), required_fuel)
    end
  end

  @spec calculate_fuel_for_launch(Decimal.t(), Decimal.t()) :: Decimal.t()
  def calculate_fuel_for_launch(mass, gravity) do
    mass
    |> Decimal.mult(gravity)
    |> Decimal.mult(Decimal.new(@launch_mult))
    |> Decimal.sub(Decimal.new(@launch_sub))
    |> Decimal.round(0, :floor)
  end

  @spec calculate_fuel_for_landing(Decimal.t(), Decimal.t()) :: Decimal.t()
  def calculate_fuel_for_landing(mass, gravity) do
    mass
    |> Decimal.mult(gravity)
    |> Decimal.mult(Decimal.new(@landing_mult))
    |> Decimal.sub(Decimal.new(@landing_sub))
    |> Decimal.round(0, :floor)
  end
end
