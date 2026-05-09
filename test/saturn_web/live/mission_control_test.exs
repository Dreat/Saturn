defmodule SaturnWeb.Live.MissionControlTest do
  use SaturnWeb.ConnCase
  import Phoenix.LiveViewTest

  # here I'd use describe to test singular business-level feature
  # so we end up with one `describe` here
  describe "plan space travel" do
    test "render main page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Add Destination"
      assert html =~ "Fuel needed for whole trip"
      assert html =~ "0 kg"
    end

    test "add new destination", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      html =
        view
        |> element("div#new_destination")
        |> render_click()

      assert html =~ "Destination"
      assert html =~ "Type of destination"
      assert html =~ "Equipment mass"
      assert html =~ "Fuel needed for this destination:"
      assert html =~ "N/A"

      # trip for total fuel has not changed
      assert html =~ "Fuel needed for whole trip"
      assert html =~ "0 kg"
    end

    # usually, I'd have id from database to work with
    # no persistance layer makes this test bit more difficult to work with
    # if no persistance layer would be a hard requirement, I'd use URL params to solve it
    # it would also address DOM id collisions
    test "add new destination with filled data", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> element("div#new_destination")
      |> render_click()

      html =
        view
        |> form("div#destination_form form")
        |> render_change(%{mass: "28801", destination: :earth, destination_type: :land})

      assert html =~ "Destination"
      assert html =~ "Type of destination"
      assert html =~ "Equipment mass"
      assert html =~ "Fuel needed for this destination:"
      refute html =~ "N/A"
      assert html =~ "13447 kg"
      # total changed
      refute html =~ "0 kg"
    end

    test "can delete destination", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> element("div#new_destination")
      |> render_click()

      view
      |> form("div#destination_form form")
      |> render_change(%{mass: "28801", destination: :earth, destination_type: :land})

      html =
        view
        |> element("div#delete_destination")
        |> render_click()

      refute html =~ "Type of destination"
      refute html =~ "Equipment mass"
      refute html =~ "Fuel needed for this destination:"
      refute html =~ "N/A"
    end
  end
end
