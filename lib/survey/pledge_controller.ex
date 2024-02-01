defmodule Survey.PledgeController do
  alias Survey.PledgeServer

  def index(req_data) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()

    %Survey.ReqData{req_data | status: 200, resp_body: inspect(pledges)}
  end

  def create(%Survey.ReqData{} = req_data, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    PledgeServer.create_pledges(name, String.to_integer(amount))

    %Survey.ReqData{req_data | status: 201, resp_body: "#{name} pledged #{amount}"}
  end
end
