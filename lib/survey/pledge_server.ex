defmodule Survey.PledgeServer do
  @process_name __MODULE__

  alias Survey.GenericServer

  # CLIENT INTERFACE

  def start() do
    IO.puts("Starting the pledge server..")
    GenericServer.start(__MODULE__, @process_name)
  end

  def recent_pledges() do
    GenericServer.call(@process_name, :recent_pledges)
  end

  def create_pledges(name, amount) when is_integer(amount) do
    GenericServer.call(@process_name, {:create_pledge, name, amount})
  end

  def clear() do
    GenericServer.cast(@process_name, :clear)
  end

  def total_pledged() do
    GenericServer.call(@process_name, :total_pledged)
  end

  # SERVER CALLBACKS

  def handle_call(:total_pledged, state) do
    total = state |> Enum.map(&elem(&1, 1)) |> Enum.sum()
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_cast(:clear, _state) do
    []
  end

  def handle_info(message, state) do
    IO.puts("wrong message key!!: #{inspect(message)}")
    state
  end

  def send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND A PROPER DATA TO SERVER
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# # # run the local state server
# alias Survey.PledgeServer
# pid = PledgeServer.start()

# send(pid, {:stop, "hammer"})

# # adding data to the server
# alias Survey.PledgeServer
# IO.inspect(PledgeServer.create_pledges("Hash", 100))
# IO.inspect(PledgeServer.create_pledges("Hash1", 200))
# IO.inspect(PledgeServer.create_pledges("Hash2", 400))
# IO.inspect(PledgeServer.create_pledges("Hash3", 500))
# IO.inspect(PledgeServer.create_pledges("Hash4", 600))
# # PledgeServer.clear()
# IO.inspect(PledgeServer.create_pledges("Hash5", 700))

# IO.inspect(PledgeServer.recent_pledges())
# IO.inspect(PledgeServer.total_pledged())
