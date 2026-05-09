defmodule SaturnWeb.Live.MissionControl do
  use SaturnWeb, :live_view

  alias Saturn.Fuel
  alias Saturn.Gravity

  # for larger html I'd move it to separate file
  # but I like to keep smaller render functions
  # for reducing the context needed
  def render(assigns) do
    ~H"""
    <div class="m-8">
      <div class="btn btn-xl btn-info" phx-click="add-destination">Add Destination</div>
      <div class="flex w-full flex-row flex-wrap">
        <%= for planet <- Map.values(@planets) do %>
          <.render_destination planet={planet} />
        <% end %>
      </div>
      <div class="stats">
        <div class="stat-title">
          Fuel needed for whole trip:
        </div>
        <div class="stat-value">
          {get_total_fuel_for_all_destinations(@planets) |> Decimal.to_string()} kg
        </div>
      </div>
    </div>
    """
  end

  # "destination" => "earth",
  # "destination_type" => "launch",
  # "id" => "b11e6722-f93d-4a29-9b7f-f20f689a6112",
  # "mass" => "1"

  # if this gets too big, I'd move it to separate,
  # resuable component
  def render_destination(assigns) do
    # TODO change mass and destination to forms
    ~H"""
    <div id={"destination-#{@planet["planet_id"]}"} class="card bg-base-100 w-96 shadow-sm m-8 p-4">
      <.form :let={p} for={@planet} phx-change="update-destination">
        <div class="flex flex-col gap-2">
          <.input
            label="Destination"
            type="select"
            field={p[:destination]}
            options={[{"Earth", :earth}, {"Moon", :moon}, {"Mars", :mars}]}
          />
          <.input
            label="Type of destination"
            type="select"
            field={p[:destination_type]}
            options={[{"Launch", :launch}, {"Landing", :land}]}
          />
          <.input
            label="Equipment mass"
            type="number"
            field={p[:mass]}
            value={Decimal.to_integer(@planet["mass"])}
            min={1}
            step={1}
          />
          <.input type="text" hidden={true} field={p[:planet_id]} value={@planet["planet_id"]} />
          <p>Fuel needed for this destination:</p>
          <%= if @planet["valid"] do %>
            <p>{@planet["total_fuel"] |> Decimal.to_string()} kg</p>
          <% else %>
            <p>N/A</p>
          <% end %>
        </div>
      </.form>
      <div
        class="btn btn-dash btn-error m-8"
        phx-click="delete-destination"
        phx-value-id={@planet["planet_id"]}
      >
        delete
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, planets: %{})}
  end

  def handle_event("add-destination", _params, %{assigns: %{planets: planets}} = socket) do
    new_id = UUID.uuid4()

    {:noreply,
     assign(socket,
       planets:
         Map.put(planets, new_id, %{
           "planet_id" => new_id,
           "valid" => false,
           "mass" => Decimal.new("0")
         })
     )}
  end

  def handle_event(
        "update-destination",
        %{
          "destination" => destination,
          "destination_type" => destination_type,
          "planet_id" => id,
          "mass" => equipment_mass
        } = _params,
        %{assigns: %{planets: planets}} = socket
      ) do
    planet = planets[id]

    new_destination = destination |> String.downcase() |> destination_to_atom()
    new_destination_type = destination_type |> String.downcase() |> destination_type_to_atom()

    planet = Map.put(planet, "destination", new_destination)
    planet = Map.put(planet, "destination_type", new_destination_type)

    result = Decimal.parse(equipment_mass) |> dbg()

    # if input is not a number or is less than 1
    planet =
      if result == :error or Decimal.lt?(elem(result, 0), Decimal.new("1")) do
        %{planet | "valid" => false}
      else
        new_mass = elem(result, 0)
        total_fuel = get_total_fuel(new_mass, new_destination, new_destination_type)
        planet = Map.put(%{planet | "valid" => true}, "mass", new_mass)
        Map.put(planet, "total_fuel", total_fuel)
      end

    planets = Map.put(planets, id, planet)

    {:noreply, assign(socket, planets: planets)}
  end

  def handle_event(
        "delete-destination",
        %{"id" => id} = _params,
        %{assigns: %{planets: planets}} = socket
      ) do
    planets = Map.delete(planets, id)

    {:noreply, assign(socket, planets: planets)}
  end

  # could also use to_existing_atom
  # but this explicitly tells what accepted values are
  defp destination_to_atom("earth"), do: :earth
  defp destination_to_atom("moon"), do: :moon
  defp destination_to_atom("mars"), do: :mars

  defp destination_type_to_atom("land"), do: :land
  defp destination_type_to_atom("launch"), do: :launch

  # total fuel for one destination
  defp get_total_fuel(mass, destination, destination_type) do
    case destination_type do
      :land -> Fuel.calculate_total_fuel_for_landing(mass, Gravity.get_gravity(destination))
      :launch -> Fuel.calculate_total_fuel_for_launch(mass, Gravity.get_gravity(destination))
    end
  end

  defp get_total_fuel_for_all_destinations(planets) do
    planets
    |> Map.values()
    |> Enum.map(fn planet -> Map.get(planet, "total_fuel", Decimal.new("0")) end)
    |> Enum.reduce(Decimal.new("0"), fn x, acc -> Decimal.add(x, acc) end)
  end
end
