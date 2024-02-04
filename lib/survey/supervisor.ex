defmodule Survey.Supervisor do
  use Supervisor

  def start_link do
    IO.puts("Starting THE Supervisor...")
    # start_link will start the supervisor process
    # and links it to the process that calls this function
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # the init function is where we can assign what functions
  # that our supervisor need to watch
  def init(:ok) do
    children = [
      Survey.KickStarter,
      {Survey.ServicesSupervisor, :timer.seconds(5)}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
