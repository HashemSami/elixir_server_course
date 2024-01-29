defmodule Survey.Api.BearController do
  def index(%Survey.ReqData{} = req_data) do
    json =
      Survey.Wildthings.list_bears()
      |> Poison.encode!()

    req_data = put_resp_content_type(req_data, "application/json")

    %{
      req_data
      | status: 200,
        resp_body: json
    }
  end

  def create(req_data, %{"type" => type, "name" => name}) do
    # req_data = put_resp_content_type(req_data, "application/json")

    %{
      req_data
      | status: 201,
        resp_body: "Created a #{type} bear named #{name}!"
    }
  end

  defp put_resp_content_type(%Survey.ReqData{resp_headers: resp_headers} = req_data, type) do
    resp_headers = Map.put(resp_headers, "Content-Type", type)

    %{
      req_data
      | resp_headers: resp_headers
    }
  end
end
