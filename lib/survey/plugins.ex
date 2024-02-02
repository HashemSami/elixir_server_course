defmodule Survey.Plugins do
  # no need for as if you want the normal struct name
  alias Survey.ReqData
  alias Survey.FourOhFourCounter

  # FourOhFourCounter.start()

  @doc """
  Logs 404 requests
  """
  def track(%ReqData{status: 404, path: path} = req_data) do
    if Mix.env() !== :test do
      IO.puts("Warning: #{path} is on the loose!")
    end

    FourOhFourCounter.bump_count(path)

    req_data
  end

  # we made the empty matching to make sure that the
  # the map passed to the function is of type ReqData
  def track(%ReqData{} = req_data), do: req_data

  def get_404_counts() do
    FourOhFourCounter.get_counts()
  end

  @doc """
  A function that will rewrite the req_data path to /wildthings
  if the req_data has a path of /wildlife
  """
  def rewrite_path(%ReqData{path: "/wildlife"} = req_data) do
    %{req_data | path: "/wildthings"}
  end

  def rewrite_path(%ReqData{path: path} = req_data) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(req_data, captures)
  end

  def rewrite_path(%ReqData{} = req_data), do: req_data
  # ======================
  def rewrite_path_captures(%ReqData{} = req_data, %{"thing" => thing, "id" => id}) do
    %{req_data | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(%ReqData{} = req_data, nil), do: req_data

  # ====================
  def log(%ReqData{} = req_data) do
    # run the logs only in the dev environment
    if Mix.env() == :dev do
      IO.inspect(req_data)
    end

    req_data
  end
end
