defmodule PlateSlate.Ordering.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlateSlate.Ordering.Order


  schema "orders" do
    field :customer_number, :integer
    field :items, :map
    field :ordered, :utc_datetime
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [:customer_number, :items, :ordered, :state])
    |> validate_required([:customer_number, :items, :ordered, :state])
  end
end
