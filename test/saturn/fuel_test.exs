defmodule Saturn.FuelTest do
  use ExUnit.Case, async: true

  alias Saturn.Fuel
  alias Saturn.Gravity

  describe "calculate_fuel_for_landing/2" do
    # for sake of saving time, putting example
    # step-by-step calculations for this test
    test "landing Apollo 11 CSM on the Earth" do
      apollo_mass = Decimal.new("28801")
      # 28801 * 9.807 * 0.033 - 42 = 9278
      expected_fuel = Decimal.new("9278")

      required_fuel = Fuel.calculate_fuel_for_landing(apollo_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)

      # continuing with
      # 9278 fuel requires 2960 more fuel
      # 2960 fuel requires 915 more fuel
      # 915 fuel requires 254 more fuel
      # 254 fuel requires 40 more fuel
      # 40 fuel requires no more fuel (result = -30)
      # for sake of correctness
      # usually I'd make a few calculations to make sure math checks out

      fuel_mass = Decimal.new("9278")
      expected_fuel = Decimal.new("2960")

      required_fuel = Fuel.calculate_fuel_for_landing(fuel_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)

      fuel_mass = Decimal.new("2960")
      expected_fuel = Decimal.new("915")

      required_fuel = Fuel.calculate_fuel_for_landing(fuel_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)

      fuel_mass = Decimal.new("915")
      expected_fuel = Decimal.new("254")

      required_fuel = Fuel.calculate_fuel_for_landing(fuel_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)

      fuel_mass = Decimal.new("254")
      expected_fuel = Decimal.new("40")

      required_fuel = Fuel.calculate_fuel_for_landing(fuel_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)

      fuel_mass = Decimal.new("40")
      # -30 is valid and expected return for this method
      # method counting total will need to handle this result properly
      expected_fuel = Decimal.new("-30")

      required_fuel = Fuel.calculate_fuel_for_landing(fuel_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)
    end
  end

  describe "calculate_total_fuel_for_landing/2" do
    test "total fuel for landing Apollo 11 CSM on the Earth" do
      apollo_mass = Decimal.new("28801")
      # 9278 + 2960 + 915 + 254 + 40 = 13447
      expected_fuel = Decimal.new("13447")

      required_fuel = Fuel.calculate_total_fuel_for_landing(apollo_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)
    end
  end

  describe "calculate_fuel_for_launch/2" do
    test "launching Apollo 11 CSM from the Earth" do
      apollo_mass = Decimal.new("28801")
      # 28801 * 9.807 * 0.042 - 33 = 11829
      expected_fuel = Decimal.new("11829")

      required_fuel = Fuel.calculate_fuel_for_launch(apollo_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)
    end
  end

  describe "calculate_total_fuel_for_launch/2" do
    test "total fuel for launchiing Apollo 11 CSM from the Earth" do
      apollo_mass = Decimal.new("28801")

      # 11829 + 4839 + 1960 + 774 + 285 + 84 + 1 = 19772
      expected_fuel = Decimal.new("19772")

      required_fuel = Fuel.calculate_total_fuel_for_launch(apollo_mass, Gravity.earth())

      assert Decimal.equal?(expected_fuel, required_fuel)
    end
  end
end
