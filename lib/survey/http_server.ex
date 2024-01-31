# ERLANG
# server() ->
#   {ok, LSock} = gen_tcp:listen(5678, [binary, {packet, 0},
#                                       {active, false}]),
#   {ok, Sock} = gen_tcp:accept(LSock),
#   {ok, Bin} = do_recv(Sock, []),
#   ok = gen_tcp:close(Sock),
#   ok = gen_tcp:close(LSock),
#   Bin.

# ELIXIR
# def server do
#   {:ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0, active: false])
#   # send accept
#   {:ok, sock} = :gen_tcp.accept(lsock)
#   # reive the data suing the accepted sock
#   {:ok, bin} = :gen_tcp.recv(sock, 0)
#   :ok = :gen_tcp.close(sock)
#   :ok = :gen_tcp.close(lsock)
#   bin
# end
defmodule Survey.HttpServer do
  @doc """
  Starts the server on the given 'port' of localhost
  """
  # ports from 0 to 1023 are reserved for the operating system
  def start(port) when is_integer(port) and port > 1023 do
    # Creates a socket to listen for client connections
    # 'listen_socket' is bound to the listening socket
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    # :gen_tcp.close(listen_socket)

    # Socket options:
    # ':binary' - open the socket in "binary" mode and deliver data as binaries
    # 'packet: :raw' - deliver the entire binary without doing any packet handling
    # 'active: false' - receive data when we're ready by calling ':gen_tcp.recv/2'
    # 'reuseaddr: true' - allows reusing the address if the listener crashes

    IO.puts("\n Listening for the connection request on port #{port}...\n")

    accept_loop(listen_socket)
  end

  @doc """
  Accepts client connection on the 'listen_socket'.
  """
  def accept_loop(listen_socket) do
    IO.puts("Waiting to accept a client connection...\n")

    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts("Connection accepted!\n")

    # Receives the request and sends a response over the client socket.
    pid = spawn(fn -> serve(client_socket) end)

    # we give control of the client socket to the
    # spawn process, so any time the the spawn close
    # the socket will be closed with it
    :ok = :gen_tcp.controlling_process(client_socket, pid)

    # Loop back to wait and accept the next connection
    accept_loop(listen_socket)
  end

  @doc """
  Receives the request on the 'client_socket' and sends a response
  back over the same socket
  """
  def serve(client_socket) do
    IO.puts("#{inspect(self())}: Working on it!")

    client_socket
    |> read_request
    |> Survey.Handler.handle()
    |> write_response(client_socket)
  end

  @doc """
  Receives a request on the 'client_socket'.
  """
  @type client_socket :: integer | float
  @spec read_request(client_socket) :: String.t()
  def read_request(client_socket) do
    # return all bytes using 0
    {:ok, request} = :gen_tcp.recv(client_socket, 0)

    IO.puts("Received request:\n")
    IO.puts(request)

    request
  end

  @doc """
  Returns a generic HTTP response
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r\r\n
    Content-Type: text/plain\r\r\n
    Content-Length: 6\r\r\n
    \r\r\n\r\r
    Hello!
    """
  end

  @doc """
  Sends the 'response' over the 'client_socket'
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts("Sent response: \n")
    IO.puts(response)

    # Closes the client socket, ending the connection
    :gen_tcp.close(client_socket)
  end
end
