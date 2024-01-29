defmodule Survey do
  @moduledoc """
  Documentation for `Survey`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Survey.hello()
      :world

  """
  def hello do
    :world
  end

  def sum([head | tail], tot) do
    sum(tail, head + tot)
  end

  def sum(_, tot), do: tot

  def triple([head | tail], trip_list) do
    triple(tail, [head * 3 | trip_list])
  end

  def triple(_, trip_list) do
    trip_list |> Enum.reverse()
  end

  def operations([head | tail], operation_func) do
    [operation_func.(head) | operations(tail, operation_func)]
  end

  def operations([], _), do: []
end

# trying post requests
# req_data = """
# POST /bears HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: application/x-www-form-urlencoded
# Content-length: 21

# name=Baloo&type=Brown
# """

# IO.puts(Survey.Handler.handle(req_data))

# trying get requests

req_data = """
GET /faq HTTP/1.1\r
Host: example.com\r
User-Agent: ExampleBrowser/1.0\r
Accept: */*\r
\r
"""

# req_data = """
# POST /api/bears HTTP/1.1\r
# Host: example.com\r
# User-Agent: ExampleBrowser/1.0\r
# Accept: */*\r
# Content-Type: application/json\r
# Content-Length: 21\r
# \r
# {"name": "Breezly", "type": "Polar"}
# """

IO.puts(Survey.Handler.handle(req_data))

# req_data = """
# GET /wildthings HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# IO.puts(Survey.Handler.handle(req_data))

# req_data = """
# GET /bears?id=7 HTTP/1.1\r\r
# Host: example.com\r\r
# User-Agent: ExampleBrowser/1.0\r\r
# Accept: */*\r\r
# \r\r
# """

# IO.puts(Survey.Handler.handle(req_data))

# # id will get assigned to 1
# "bear/" <> id = "bear/1"

# req_data = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# IO.puts(Survey.Handler.handle(req_data))

# req_data = """
# GET /bears/new HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# IO.puts(Survey.triple([1, 2, 3, 4, 5], []))
# IO.inspect(Survey.triple([1, 2, 3, 4, 5], []))

# IO.inspect(Survey.operations([1, 2, 3, 4, 5], &(&1 * 5)))
