defmodule CLI do

  @commands ["exit", "echo", "type"]

  def main(args) do
    # TODO: Uncomment the code below to pass the first stage
    IO.write("$ ")
    command = IO.gets("") |> String.trim()
    evaluate(command)
    main(args)

  end

  def evaluate("exit") do
    exit(:normal)
  end

  def evaluate("echo "<> cmd) do
    IO.puts(cmd)
  end

  def evaluate("type "<> cmd) do
    if Enum.member?(@commands, cmd) do
      IO.puts("#{cmd} is a shell builtin")
    else
      IO.puts("#{cmd}: not found")
    end
  end

  def evaluate(cmd) do
    IO.puts("#{cmd}: command not found")
  end
end
