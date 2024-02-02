defmodule Survey.FourOhFourCounter do
  alias Survey.GenericServer

  @counter_server __MODULE__
  def start() do
    GenericServer.start(__MODULE__, @counter_server, %{})
  end

  def bump_count(path) do
    GenericServer.call(@counter_server, {:bump_count, path})
  end

  def get_count(path) do
    GenericServer.call(@counter_server, {:get_count, path})
  end

  def get_counts() do
    GenericServer.call(@counter_server, :get_counts)
  end

  def reset_counter() do
    GenericServer.cast(@counter_server, :reset)
  end

  # SERVER CALLBACKS
  def handle_call({:bump_count, path}, state) do
    updated_state = Map.update(state, path, 1, &(&1 + 1))
    {:ok, updated_state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)
    {count, state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end

  def handle_cast(:reset, _state) do
    %{}
  end
end
