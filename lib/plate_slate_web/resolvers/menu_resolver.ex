defmodule PlateSlateWeb.MenuResolver do
  alias PlateSlate.{ Menu }

  def all_menu_items(_root,args, _ctx) do
    { :ok, Menu.list_items(args) }
    # {:ok, Repo.all(Menu.Item)}
  end

  def search(_root, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end

  def create_item(_roo, %{input: params}, _) do
    case Menu.create_item(params) do
      {:error, changeset} ->
        {:error, message: "Could not create menu item", details: error_details(changeset)}
      {:ok, _} = success ->
        success
    end
  end

  def error_details(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, _} -> msg end)
  end

end
