defmodule Survey.PledgeServerGen do
  @process_name __MODULE__

  # GenServer requires the use of all the six handlers to be
  # implemented.
  # since we only using two, we can use the 'use' macro
  # the will inject the default implementations into
  # our pledge server module.
  # we are implementing the handle call and cast the will
  # overwrite the default functions
  use GenServer
  # CLIENT INTERFACE

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def start() do
    IO.puts("Starting the pledge server..")
    GenServer.start(__MODULE__, %State{}, name: @process_name)
  end

  def recent_pledges() do
    GenServer.call(@process_name, :recent_pledges)
  end

  def create_pledges(name, amount) when is_integer(amount) do
    GenServer.call(@process_name, {:create_pledge, name, amount})
  end

  def set_cache_size(size) do
    GenServer.call(@process_name, {:set_cache_size, size})
  end

  def clear() do
    GenServer.cast(@process_name, :clear)
  end

  def total_pledged() do
    GenServer.call(@process_name, :total_pledged)
  end

  # SERVER CALLBACKS
  # init wil automatically called by gen server
  # so we can define an initial values for our state here
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %State{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_call(:total_pledged, _from, %State{} = state) do
    total = state.pledges |> Enum.map(&elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, %State{} = state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, %State{} = state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    {:reply, id, %{state | pledges: cached_pledges}}
  end

  def handle_call({:set_cache_size, size}, _from, %State{} = state) do
    resized_pledges = Enum.take(state.pledges, size)
    {:reply, :ok, %State{state | cache_size: size, pledges: resized_pledges}}
  end

  def handle_cast(:clear, state) do
    {:noreply, %State{state | pledges: []}}
  end

  def handle_info(message, state) do
    # this will overwrite the error message generated
    # by the gen server when unregistered messaged
    # is called to the server
    IO.puts("wrong message key!!: #{inspect(message)}")
    {:noreply, state}
  end

  def send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND A PROPER DATA TO SERVER
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  def fetch_recent_pledges_from_service do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FORM SERVICE

    # example return
    [
      {"Hashem", 40000},
      {"Sara", 988},
      {"Sara", 988},
      {"Sara", 988},
      {"Sara", 988},
      {"Sara", 988},
      {"Sara", 988}
    ]
  end
end

# # # run the local state server
# alias Survey.PledgeServerGen
# {:ok, pid} = PledgeServerGen.start()
# send(pid, {:stop, "hammer"})
# PledgeServerGen.set_cache_size(4)
# # adding data to the server
# alias Survey.PledgeServerGen
# IO.inspect(PledgeServerGen.create_pledges("Hash", 100))
# IO.inspect(PledgeServerGen.create_pledges("Hash1", 200))
# IO.inspect(PledgeServerGen.create_pledges("Hash2", 400))
# IO.inspect(PledgeServerGen.create_pledges("Hash3", 500))
# IO.inspect(PledgeServerGen.create_pledges("Hash4", 600))
# # PledgeServerGen.clear()
# IO.inspect(PledgeServerGen.create_pledges("Hash5", 700))

# IO.inspect(PledgeServerGen.recent_pledges())
# IO.inspect(PledgeServerGen.total_pledged())

# :sys.get_state(pid)
