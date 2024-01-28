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
end
