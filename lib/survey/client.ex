defmodule Survey.Client do
  def send(req_data, port) do
    port
    |> connect_to_server()
    |> send_request(req_data)
    |> receive_res
  end

  def connect_to_server(port) do
    # to make it runnable on one machine
    some_host_in_net = ~c'localhost'

    {:ok, server_socket} =
      :gen_tcp.connect(some_host_in_net, port, [:binary, packet: :raw, active: false])

    server_socket
  end

  def send_request(server_socket, req_data) do
    :gen_tcp.send(server_socket, req_data)
    server_socket
  end

  def receive_res(server_socket) do
    {:ok, res} = :gen_tcp.recv(server_socket, 0)

    :gen_tcp.close(server_socket)
    res
  end
end
