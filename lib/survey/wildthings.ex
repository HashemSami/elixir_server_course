defmodule Survey.Wildthings do
  @db_path Path.expand("db", File.cwd!())

  alias Survey.Bear

  # def list_bears do
  #   case File.read(Path.join(@db_path, "bears.json")) do
  #     {:ok, bears_data} -> Poison.decode!(bears_data, as: %{"bears" => [%Bear{}]})["bears"]
  #     {:error, _reason} -> "error parsing the file"
  #   end
  # end
  def list_bears do
    @db_path
    |> Path.join("bears.json")
    |> read_json
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  defp read_json(source) do
    case File.read(source) do
      {:ok, contents} ->
        contents

      {:error, reason} ->
        IO.inspect("Error reading #{source}: #{reason}")
        "[]"
    end
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear()
  end

  def delete_bear(id) when is_integer(id) do
    list_bears()
    |> Enum.find(fn b -> b.id == id end)
  end

  def delete_bear(id) when is_binary(id) do
    id |> String.to_integer() |> delete_bear()
  end
end
