defmodule Survey.Api.BearController do
  def index(req_data) do
    json =
      Survey.Wildthings.list_bears()
      |> Poison.encode!()

    %{req_data | status: 200, resp_content_type: "application/json", resp_body: json}
  end
end
