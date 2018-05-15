defmodule PlateSlate.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :customer_number, :integer
      add :items, :map
      add :ordered, :utc_datetime, null: false, default: fragment("NOW()")
      add :state, :string

      timestamps()
    end

  end
end
