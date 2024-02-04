defmodule Survey.KickStarter do
  use GenServer

  def start_link do
    IO.puts("Starting the kickstarter...")

    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # CLIENT INTERFACE

  def get_server() do
    GenServer.call(__MODULE__, :get_server)
  end

  # SERVER CALLBACKS
  def init(:ok) do
    # this will flag a message with atom {:EXIT, _pid, _msg}
    # that need to be handled by the handel info
    # to restart the server
    # this is called trapping the exit of the linked
    # process, ans will not terminate the other linked precesses
    Process.flag(:trap_exit, true)

    server_pid = start_server()
    # this will be stored on the GenServer state
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HTTP server exited #{inspect(reason)}")
    server_pid = start_server()
    {:noreply, server_pid}
  end

  def handle_call(:get_server, _from, state) do
    {:reply, state, state}
  end

  defp start_server() do
    IO.puts("Starting the HTTP server...")
    port = Application.get_env(:survey, :port)
    server_pid = spawn_link(Survey.HttpServer, :start, [port])
    # this will create a bidirectional links between the
    # http and the gen server
    # Process.link(server_pid)
    Process.register(server_pid, :http_server)
    server_pid
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
