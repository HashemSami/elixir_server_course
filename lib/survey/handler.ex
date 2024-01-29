defmodule Survey.Handler do
  @moduledoc """
  Handles HTTP req_datas.
  """
  alias Survey.ReqData
  alias Survey.BearController

  import Survey.Plugins, only: [rewrite_path: 1, track: 1, log: 1]
  import Survey.FileHandler, only: [serve_page: 2, serve_md_page: 2]
  import Survey.Parser

  def handle(req_data) do
    req_data
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def put_content_length(%ReqData{resp_headers: resp_headers, resp_body: resp_body} = req_data) do
    resp_headers = Map.put(resp_headers, "Content-Length", String.length(resp_body))
    %{req_data | resp_headers: resp_headers}
  end

  # ======================
  def route(%ReqData{method: "GET", path: "/wildthings"} = req_data) do
    # Map.put(req_data, :resp_body, "Bears, Lions, Tigers")
    # same as
    %{req_data | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%ReqData{method: "GET", path: "/bears"} = req_data) do
    BearController.index(req_data)
  end

  def route(%ReqData{method: "GET", path: "/api/bears"} = req_data) do
    Survey.Api.BearController.index(req_data)
  end

  def route(%ReqData{method: "GET", path: "/bears/new"} = req_data) do
    serve_page(req_data, "form")
  end

  def route(%ReqData{method: "GET", path: "/bears/" <> id, params: params} = req_data) do
    params = Map.put(params, "id", id)

    BearController.show(req_data, params)
  end

  def route(%ReqData{method: "DELETE", path: "/bears/" <> id, params: params} = req_data) do
    params = Map.put(params, "id", id)

    BearController.delete(req_data, params)
  end

  def route(%ReqData{method: "POST", path: "/bears", params: params} = req_data) do
    BearController.create(req_data, params)
  end

  def route(%ReqData{method: "POST", path: "/api/bears", params: params} = req_data) do
    Survey.Api.BearController.create(req_data, params)
  end

  def route(%ReqData{method: "GET", path: "/about"} = req_data) do
    serve_page(req_data, "about")
  end

  def route(%ReqData{method: "GET", path: "/faq"} = req_data) do
    serve_md_page(req_data, "faq")
  end

  # its important to put the matching function that
  # handles all variables at the last, acting like
  # default function
  def route(%ReqData{path: path} = req_data) do
    %{req_data | status: 404, resp_body: "No #{path} here!"}
  end

  # ======================

  def format_response_headers(resp_headers) do
    for {key, value} <- resp_headers do
      "#{key}: #{value}\r"
    end
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\r\n")
  end

  def format_response(%ReqData{resp_headers: resp_headers} = req_data) do
    """
    HTTP/1.1 #{ReqData.full_status(req_data)}\r
    #{format_response_headers(resp_headers)}
    \r
    #{req_data.resp_body}
    """
  end
end
