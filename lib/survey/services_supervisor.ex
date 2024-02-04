defmodule Survey.ServicesSupervisor do
  use Supervisor

  def start_link(interval) do
    IO.puts("Starting the services Supervisor...")
    # start_link will start the supervisor process
    # and links it to the process that calls this function
    Supervisor.start_link(__MODULE__, interval, name: __MODULE__)
  end

  # the init function is where we can assign what functions
  # that our supervisor need to watch
  def init(interval) do
    children = [
      Survey.PledgeServerGen,
      Survey.FourOhFourCounter,
      {Survey.SensorServer, interval}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor,
      restart: :permanent,
      shutdown: :infinity
    }
  end
end
