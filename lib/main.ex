defmodule CLI do
  def main(args) do
    # TODO: Uncomment the code below to pass the first stage
    IO.write("$ ")
    command = IO.gets("") |> String.trim()

    case command do
      "exit" -> exit(:normal)
      "echo "<> value -> IO.puts(value)
      _ -> IO.puts("#{command}: command not found")
      main(args)
    end

  end
end
