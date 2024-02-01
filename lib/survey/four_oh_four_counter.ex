defmodule Survey.FourOhFourCounter do
  @counter_server :serv
  def start() do
    {:ok, agent} = Agent.start(fn -> %{} end)

    Process.register(agent, @counter_server)
    @counter_server
  end

  def bump_count(path) do
    Agent.update(@counter_server, fn state -> Map.update(state, path, 1, &(&1 + 1)) end)
  end

  # ======================================
  # defp update_state(state, path) when not is_map_key(state, path) do
  #   Map.put(state, path, 1)
  # end

  # defp update_state(state, path) do
  #   %{state | path => state[path] + 1}
  # end

  # ======================================

  def get_count(path) do
    Agent.get(@counter_server, fn state -> state[path] end)
  end

  def get_counts() do
    Agent.get(@counter_server, fn state -> state end)
  end
end
