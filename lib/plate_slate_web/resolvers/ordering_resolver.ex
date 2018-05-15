defmodule PlateSlateWeb.OrderingResolver do
  alias PlateSlate.Ordering

  def place_order(_root, %{input: place_order_input}, _ctx) do
    {:ok,order} = Ordering.create_order(place_order_input)
    {:ok, %{order: order}}
  end
end
