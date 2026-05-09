defmodule Saturn.Gravity do
  @moduledoc """
  Module containing constant values for gravity
  """

  @spec earth() :: Decimal.t()
  def earth(), do: Decimal.new("9.807")
  @spec moon() :: Decimal.t()
  def moon(), do: Decimal.new("1.62")
  @spec mars() :: Decimal.t()
  def mars(), do: Decimal.new("3.711")
end
