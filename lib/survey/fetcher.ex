defmodule Survey.Fetcher do
  alias Survey.VideoCam

  def async(fun) do
    # assigning the current precess pid to the parent variable
    # which is the request handling process
    parent = self()

    # we first span all the processes first so we don't get blocked by the
    # receive code.
    spawn(fn -> send(parent, {self(), :result, fun.()}) end)
  end

  def get_result(pid) do
    # receive code should be at the end of our process so we don't
    # have to wait for the messages to arrive
    receive do
      # the pin operator will make sure that
      # we are pattern matching with the exact
      # value in the function argument
      # not bind it to a new value
      {^pid, :result, value} -> value
    end
  end
end
