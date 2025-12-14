defmodule CLI do
  def main(args) do
    # TODO: Uncomment the code below to pass the first stage
    IO.write("$ ")
    command = IO.gets("") |> String.trim()
    IO.puts("#{command}: command not found")
    main(args)
  end
end
