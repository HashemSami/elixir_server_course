defmodule Survey.Parser do
  require Logger
  alias Survey.ReqData, as: ReqData

  def parse(req_data) do
    # this will return a list with tow element
    [top, params_string] = String.split(req_data, "\r\r\n\r\r\n")

    [request_line | header_lines] = String.split(top, "\r\r\n")

    headers = parse_headers(header_lines)
    # get the header parts from the request_line
    [method, path, _version] = String.split(request_line, " ")

    %ReqData{
      method: method,
      path: path,
      params: parse_params(headers["Content-Type"], params_string),
      headers: headers
    }
  end

  # def parse_headers([header | tail], headers) do
  #   [key, value] = String.split(header, ": ")

  #   headers = Map.put(headers, key, value)

  #   parse_headers(tail, headers)
  # end

  # def parse_headers([], headers), do: headers

  def parse_headers(headers) do
    Enum.reduce(headers, %{}, fn cur, acc ->
      [key, value] = String.split(cur, ": ")
      Map.put(acc, key, value)
    end)
  end

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
