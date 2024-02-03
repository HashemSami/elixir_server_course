defmodule Survey.FourOhFourCounter do
  use GenServer

  @counter_server __MODULE__

  def start() do
    IO.puts("Starting the Four Oh Four Counter server..")

    GenServer.start(__MODULE__, %{}, name: @counter_server)
  end

  def bump_count(path) do
    GenServer.call(@counter_server, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(@counter_server, {:get_count, path})
  end

  def get_counts() do
    GenServer.call(@counter_server, :get_counts)
  end

  def reset_counter() do
    GenServer.cast(@counter_server, :reset)
  end

  # SERVER CALLBACKS

  def init(state) do
    {:ok, state}
  end

  def handle_call({:bump_count, path}, _from, state) do
    updated_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, :ok, updated_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end
end
