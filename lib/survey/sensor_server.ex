defmodule Survey.SensorServer do
  @name :sensor_server
  # :timer.minutes(60)
  # @refresh_interval :timer.seconds(5)

  use GenServer

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.minutes(60)
  end

  # CLIENT INTERFACE

  def start_link(interval) do
    GenServer.start_link(__MODULE__, %State{refresh_interval: interval}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(time) do
    GenServer.cast(@name, {:set_refresh_interval, time})
  end

  # SERVER CALLBACKS

  def init(state) do
    initial_sensor_data = run_task_to_get_sensor_data()

    new_state = %State{state | sensor_data: initial_sensor_data}

    # a task to refresh the sensor data every 5 sec
    schedule_refresh(new_state.refresh_interval)

    {:ok, new_state}
  end

  def handle_info(:refresh, %State{} = state) do
    IO.puts("refreshing the cache...")
    refreshed_sensor_data = run_task_to_get_sensor_data()
    new_state = %{state | sensor_data: refreshed_sensor_data}

    schedule_refresh(state.refresh_interval)

    {:noreply, new_state}
  end

  def handle_info(message, state) do
    # this will overwrite the error message generated
    # by the gen server when unregistered messaged
    # is called to the server
    IO.puts("wrong message key!!: #{inspect(message)}")
    {:noreply, state}
  end

  defp schedule_refresh(refresh_interval) do
    Process.send_after(self(), :refresh, refresh_interval)
  end

  def handle_cast({:set_refresh_interval, time}, %State{} = state) do
    new_state = %{state | refresh_interval: time}

    schedule_refresh(new_state.refresh_interval)
    {:noreply, new_state}
  end

  def handle_call(:get_sensor_data, _from, %State{} = state) do
    {:reply, state.sensor_data, state}
  end

  def run_task_to_get_sensor_data() do
    IO.puts("running Tasks to get sensor data...")

    task = Task.async(fn -> Survey.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      # this will return 3 pids after running all processes
      # note that if the Task generated an error, the hole server will
      # crash
      |> Enum.map(&Task.async(fn -> Survey.VideoCam.get_snapshot(&1) end))
      # then will receive the messages through this pipe
      # the Task has a default timeout of 5 second then it will raise an error
      |> Enum.map(&Task.await/1)

    bigfoot_location = Task.await(task)

    %{snapshots: snapshots, location: bigfoot_location}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
