defmodule Survey.ReqData do
  # the struct will have the same name of the module
  # that is why you can only define one struct per module

  # keyword_list data structure
  defstruct method: "",
            path: "",
            status: nil,
            params: %{},
            headers: %{},
            resp_content_type: "text/html",
            resp_body: ""

  def full_status(req_data) do
    "#{req_data.status} #{status_reason(req_data.status)}"
  end

  # private function
  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end
