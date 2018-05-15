defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlateWeb.MenuResolver
  alias PlateSlateWeb.OrderingResolver

  import_types __MODULE__.MenuTypes
  import_types __MODULE__.OrderingTypes

  subscription do
    field :new_order, :order do

      config fn _args, _info ->
        {:ok, topic: "*"}
      end

      resolve fn root, _, _ ->
        IO.inspect(root)
        {:ok, root}
      end
    end
  end

  query do
    field :menu_items, list_of(:menu_item) do
      arg :filter, :menu_item_filter
      arg :order, type: :sort_order, default_value: :asc
      resolve &MenuResolver.all_menu_items/3
    end

    field :search, list_of(:search_result) do
      arg :matching, non_null(:string)
      resolve &MenuResolver.search/3
    end
  end

  mutation do
    field :create_menu_item, :menu_item do
      arg :input, non_null(:menu_item_input)
      resolve &MenuResolver.create_item/3
    end

    field :place_order, :order_result do
      arg :input, non_null(:place_order_input)
      resolve &OrderingResolver.place_order/3
    end
  end

  scalar :date do
    parse fn input ->
      case Date.from_iso8601(input.value) do
        {:ok, date} -> {:ok, date}
        _ -> :error
      end
    end

    serialize fn date ->
      Date.to_iso8601(date)
    end
  end

  scalar :decimal do
    parse fn %{value: value} ->
      Decimal.parse(value)
    end
    serialize &to_string/1
  end

  enum :sort_order do
    value :asc
    value :desc
  end
end
