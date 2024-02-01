defmodule Survey.PledgeController do
  alias Survey.PledgeServer

  def index(req_data) do
    pledges = PledgeServer.recent_pledges()

    %Survey.ReqData{req_data | status: 200, resp_body: inspect(pledges)}
  end

  def create(%Survey.ReqData{} = req_data, %{"name" => name, "amount" => amount}) do
    PledgeServer.create_pledges(name, String.to_integer(amount))
    %Survey.ReqData{req_data | status: 201, resp_body: "#{name} pledged #{amount}"}
  end
end
