defmodule Survey.Client do
  def start(port) do
    port
    |> connect_to_server()
    |> send_request
    |> receive_req
  end

  def connect_to_server(port) do
    # to make it runnable on one machine
    some_host_in_net = ~c'localhost'

    {:ok, server_socket} =
      :gen_tcp.connect(some_host_in_net, port, [:binary, packet: :raw, active: false])

    server_socket
  end

  def send_request(server_socket) do
    req_data = """
    GET /faq HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r\n\r
    """

    :gen_tcp.send(server_socket, req_data)
  end

  def receive_req(server_socket) do
    {:ok, request} = :gen_tcp.recv(server_socket, 0)

    IO.puts(request)
    :gen_tcp.close(server_socket)
  end
end
