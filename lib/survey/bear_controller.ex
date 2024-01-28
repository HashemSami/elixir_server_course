defmodule Survey.BearController do
  alias Survey.Wildthings
  alias Survey.Bear
  alias Survey.BearView

  # @templates_path Path.expand("templates", File.cwd!())

  # \\ is where you can set a default value for
  # a parameter
  # defp render(req_data, template, bindings \\ []) do
  #   content =
  #     @templates_path
  #     |> Path.join(template)
  #     |> EEx.eval_file(bindings)
  # end

  # this called the capture operator &
  # its a shortcut where we can send the argument
  # of the outer function to the inner function
  def index(req_data) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    # render(req_data, "index.html.eex", bears: bears)
    %{req_data | status: 200, resp_body: BearView.index(bears)}
  end

  def show(req_data, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    # render(req_data, "show.html.eex", bear: BearView.show(bear))
    %{req_data | status: 200, resp_body: BearView.show(bear)}
  end

  def create(req_data, %{"type" => type, "name" => name}) do
    %{
      req_data
      | status: 201,
        resp_body: "Crated a #{type} bear named #{name}"
    }
  end

  def delete(req_data, %{"id" => id}) do
    deleted_bear = Wildthings.delete_bear(id)

    %{
      req_data
      | status: 201,
        resp_body: "Bear #{deleted_bear.id} with name #{deleted_bear.name} is deleted"
    }
  end
end
