defmodule Survey.PledgeServer do
  @process_name :pledge_server

  # CLIENT INTERFACE

  def start(initial_state \\ []) do
    IO.puts("Starting the pledge server..")
    # spawn(Survey.PledgeServer, :listen_loop, [[]])
    # same
    pid = spawn(__MODULE__, :listen_loop, [initial_state])

    # instead of referencing the pid each time we want to
    # interact with the process, we can register a process
    # to an atom, and use this atom to referencing the process
    Process.register(pid, @process_name)
    pid
  end

  def recent_pledges() do
    # return the most recent pledges (cache)
    # requesting the server to send the state to
    # the current process mailbox.
    # !! self() here will be the id to which service made
    # this function call
    send(@process_name, {self(), :recent_pledges})

    # collecting the data from the mailbox
    receive do
      {:response, pledges} -> pledges
    end
  end

  def create_pledges(name, amount) when is_integer(amount) do
    # since the listen loop is handling caching and adding the
    # the data to the database, we can only send the message to the
    # cache server
    send(@process_name, {self(), :create_pledge, name, amount})

    # receiving the created pledge id to make sure
    # that the pledge is added to the server
    receive do
      {:response, status} -> status
    end
  end

  def total_pledged() do
    send(@process_name, {self(), :total_pledged})

    # receiving the created pledge id to make sure
    # that the pledge is added to the server
    receive do
      {:response, total} -> total
    end
  end

  # SERVER CODE

  def listen_loop(cache_state) do
    # will create a receive block that will continue
    # delivering messages the was cached in the process
    receive do
      {sender, :create_pledge, name, amount} ->
        # code
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(cache_state, 2)
        new_cache = [{name, amount} | most_recent_pledges]

        send(sender, {:response, id})
        listen_loop(new_cache)

      # message code so can the sender request
      # the current state from the process
      {sender, :recent_pledges} ->
        send(sender, {:response, cache_state})
        listen_loop(cache_state)

      {sender, :total_pledged} ->
        total = cache_state |> Enum.map(&elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(cache_state)

      # this will flush the data from the message box
      # if there is no match with the above code
      unexpected ->
        IO.puts("Unexpected messaged: #{inspect(unexpected)}")
        listen_loop(cache_state)
    end
  end

  def send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND A PROPER DATA TO SERVER
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# # run the local state server
# alias Survey.PledgeServer
# PledgeServer.start()

# # adding data to the server
# alias Survey.PledgeServer
# IO.inspect(PledgeServer.create_pledges("Hash", 100))
# IO.inspect(PledgeServer.create_pledges("Hash1", 200))
# IO.inspect(PledgeServer.create_pledges("Hash2", 400))
# IO.inspect(PledgeServer.create_pledges("Hash3", 500))
# IO.inspect(PledgeServer.create_pledges("Hash4", 600))
# IO.inspect(PledgeServer.create_pledges("Hash5", 700))

# IO.inspect(PledgeServer.recent_pledges())
# IO.inspect(PledgeServer.total_pledged())
