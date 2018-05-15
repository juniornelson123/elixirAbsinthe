defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true
  import Ecto.Query, only: [from: 2]

  alias PlateSlate.{ Repo, Menu }

  setup do
    PlateSlate.Seeds.run()
  end


  @query_order """
  query($order: String){
    menuItems(order: $order){
      name
    }
  }
  """

  @query """
  {
    menuItems{
      name
    }
  }
  """

  @query_filter """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
  } }
  """


  @query_filter_date """
  query($filter: MenuItemFilter!){
    menuItems(filter: $filter) {
      name
      addedOn
    }
  }
  """

  test "menuItems field returns menu items" do
    conn = build_conn()
    conn = get conn, "/api", query: @query

    names_hash = Repo.all(from m in Menu.Item, order_by: [asc: :name], select: m.name) |> Enum.map &(%{"name" => &1})

    assert json_response(conn, 200) == %{
      "data" => %{
        "menuItems" => names_hash
      }
    }
  end


  @variables %{ "order" => "DESC" }
  test "menuItems field returns items descending using literals" do
    response = get(build_conn(), "/api", query: @query_order, variables: @variables)
    names_hash = Repo.all(from m in Menu.Item, select: m.name, order_by: [desc: :name]) |> Enum.map &(%{"name" => &1})
    assert %{
      "data" => %{
        "menuItems" => names_hash
      }
    } == json_response(response, 200)
  end

  @variables %{filter: %{"tag" => "Vegetarian", "category" => "Sandwiches"}}
  test "menuItems field returns menuItems, filtering with a variable" do
    response = get(build_conn(), "/api", query: @query_filter, variables: @variables)
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
    } == json_response(response, 200)
  end

  @variables %{filter: %{"addedBefore" => "2018-01-20"}}
  test "menuItems filtered by custom scalar" do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")
    %PlateSlate.Menu.Item{
      name: "Nelson Junior",
      added_on: ~D[2018-01-01],
      price: 2.50,
      category: sides
    } |> PlateSlate.Repo.insert!

    response = get(build_conn(), "/api", query: @query_filter_date, variables: @variables)

    assert json_response(response, 200) == %{
      "data" => %{
        "menuItems" => [
          %{"name"=>"Nelson Junior", "addedOn"=>"2018-01-01"}
        ]
      }
    }
  end
end
