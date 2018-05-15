defmodule PlateSlate.Ordering.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlateSlate.Ordering.Order


  schema "orders" do
    field :customer_number, :integer, read_after_writes: true
    field :ordered, :utc_datetime, read_after_writes: true
    field :state, :string

    embeds_many :items, PlateSlateWeb.Ordering.Item
    timestamps()
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [:customer_number,:ordered, :state])
    |> cast_embed(:items)
  end
end
