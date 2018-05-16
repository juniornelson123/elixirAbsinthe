defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlateWeb.MenuResolver
  alias PlateSlateWeb.OrderingResolver

  import_types __MODULE__.MenuTypes
  import_types __MODULE__.OrderingTypes

  object :test do
    field :name, :string
  end

  subscription do
    field :new_order, :order do

      config fn _args, _info ->
        {:ok, topic: "pedido"}
      end

      trigger :place_order, topic: fn _ ->
        "pedido"
      end

      resolve fn root, _, _ ->
        IO.inspect(root)
        {:ok, root.order}
      end
    end

    field :update_item, :menu_item do
      arg :id, non_null(:id)

      config fn args, _ ->
        {:ok, topic: args.id}
      end

      trigger :update_menu_item, topic: fn item ->
        IO.inspect(item.id)
        item.id
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
    field :update_menu_item, :menu_item do
      arg :id, :id
      arg :input, :menu_item_update_input

      resolve &MenuResolver.update_item/3
    end

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
