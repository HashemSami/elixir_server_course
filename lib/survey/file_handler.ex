defmodule Survey.FileHandler do
  @pages_path Path.expand("../../pages", __DIR__)

  # or this line, CWD is always returning the root directory
  # of our application
  @pages_path Path.expand("pages", File.cwd!())

  def serve_page(req_data, page) do
    # this will reference the pager directory wherever I call
    # the script from
    @pages_path
    |> Path.join("#{page}.html")
    |> File.read()
    |> handle_file(req_data)
  end

  # ======================

  def handle_file({:ok, contents}, req_data) do
    %{req_data | status: 200, resp_body: contents}
  end

  def handle_file({:error, :enoent}, req_data) do
    %{req_data | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, req_data) do
    %{req_data | status: 500, resp_body: "File error: #{reason}"}
  end
end
