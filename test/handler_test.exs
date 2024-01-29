defmodule HandlerTest do
  use ExUnit.Case
  doctest Survey.Parser

  import Survey.Handler, only: [handle: 1]

  test "deleting an item from the bear data and returning the deleted item" do
    request = """
    DELETE /bears?id=7 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    expect =
      "HTTP/1.1 201 Created\r\r\nContent-Type: text/html\r\r\nContent-Length: 33\r\r\n\r\r\nBear 7 with name Rosie is deleted\r\n"

    req_data = handle(request)

    # assert req_data.status == 201

    assert req_data == expect
  end

  test "POST /api/bears" do
    request = """
    POST /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/json\r
    Content-Length: 21\r
    \r
    {"name": "Breezly", "type": "Polar"}
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 201 Created\r
           Content-Type: text/html\r
           Content-Length: 35\r
           \r
           Created a Polar bear named Breezly!
           """
  end
end
