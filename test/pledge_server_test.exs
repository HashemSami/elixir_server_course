defmodule PledgeServerTest do
  use ExUnit.Case

  alias Survey.PledgeServer

  test "retrieving the recent pledges will only return three items" do
    PledgeServer.start()

    PledgeServer.create_pledges("Hash", 100)
    PledgeServer.create_pledges("Hash1", 200)
    PledgeServer.create_pledges("Hash2", 400)
    PledgeServer.create_pledges("Hash3", 500)
    PledgeServer.create_pledges("Hash4", 600)
    PledgeServer.create_pledges("Hash5", 700)

    most_recent_pledges = [{"Hash5", 700}, {"Hash4", 600}, {"Hash3", 500}]

    assert most_recent_pledges == PledgeServer.recent_pledges()
  end
end
