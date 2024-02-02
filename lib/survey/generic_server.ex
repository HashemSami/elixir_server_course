defmodule Survey.GenericServer do
  def start(callback_module, name, initial_state \\ []) do
    IO.puts("Starting state server..")
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  @doc """
  will cast a message to the server without waiting for a response
  """
  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, callback_module) do
    # will create a receive block that will continue
    # delivering messages the was cached in the process
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} when is_atom(message) ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      # this will flush the data from the message box
      # if there is no match with the above code
      unexpected ->
        IO.puts("Unexpected messaged: #{inspect(unexpected)}")
        listen_loop(state, callback_module)
    end
  end
end
