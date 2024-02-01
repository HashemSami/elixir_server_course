defmodule HandlerTest do
  use ExUnit.Case

  import Survey.Handler, only: [handle: 1]

  # spawn(Survey.HttpServer, :start, [4000])

  test "deleting an item from the bear data and returning the deleted item" do
    request = """
    DELETE /bears?id=7 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r\n\r
    """

    expect =
      "HTTP/1.1 201 Created\r\r\nContent-Type: text/html\r\r\nContent-Length: 33\r\r\n\r\n\r\r\nBear 7 with name Rosie is deleted\r\n\r\n"

    req_data = handle(request)

    # assert req_data.status == 201

    assert req_data == expect
  end

  # test "POST /api/bears" do
  #   request = """
  #   POST /api/bears HTTP/1.1\r
  #   Host: example.com\r
  #   User-Agent: ExampleBrowser/1.0\r
  #   Accept: */*\r
  #   Content-Type: application/json\r
  #   Content-Length: 21\r
  #   \r\n\r
  #   {"name": "Breezly", "type": "Polar"}
  #   """

  #   response = handle(request)

  #   assert response == """
  #          HTTP/1.1 201 Created\r
  #          Content-Type: text/html\r
  #          Content-Length: 35\r
  #          \r\n\r
  #          Created a Polar bear named Breezly!\r\n
  #          """
  # end

  test "HttpServer test" do
    req_data = """
    GET /faq HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r\n\r
    """

    parent = self()

    max_concurrent_requests = 5

    for _ <- 1..max_concurrent_requests do
      spawn(fn ->
        res = Survey.Client.send(req_data, 4000)

        # Send the response back to the parent
        send(parent, {:ok, res})
      end)
    end

    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert String.slice(response, 0..39) == "HTTP/1.1 200 OK\r\r\nContent-Type: text/html"
      end
    end
  end

  test "HttpServer test using Task" do
    # req_data = """
    # GET /faq HTTP/1.1\r
    # Host: example.com\r
    # User-Agent: ExampleBrowser/1.0\r
    # Accept: */*\r
    # \r\n\r
    # """

    url = "http://localhost:4000/faq"

    # spawn(Survey.HttpServer, :start, [4000])

    max_concurrent_requests = 5

    [1..max_concurrent_requests]
    # |> Enum.map(fn _ -> Task.async(Survey.Client, :send, [req_data, 4000]) end)
    |> Enum.map(fn _ -> Task.async(HTTPoison, :get, [url]) end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_response/1)
  end

  defp assert_response({:ok, response}) do
    assert String.slice(response.body, 0..39) == "\r\r\n<h1>\nFrequently Asked Questions</h1>\n<"
  end

  test "HttpServer test using Task on multi urls" do
    urls = [
      "http://localhost:4000/wildthings",
      "http://localhost:4000/bears",
      "http://localhost:4000/bears/1",
      "http://localhost:4000/wildlife",
      "http://localhost:4000/api/bears"
    ]

    # spawn(Survey.HttpServer, :start, [4000])

    urls
    |> Enum.map(&Task.async(HTTPoison, :get, [&1]))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_response_200/1)
  end

  defp assert_response_200({:ok, response}) do
    assert response.status_code == 200
  end
end
