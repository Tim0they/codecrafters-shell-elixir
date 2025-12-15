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
      case find_file(cmd) do
        [""] -> IO.puts("#{cmd}: not found")
        file -> IO.puts("#{cmd} is #{file}")
      end

    end
  end

  def evaluate(cmd) do
    IO.puts("#{cmd}: command not found")
  end



  defp get_file(files, filename, dir) do
    if Enum.member?(files, filename) do
      Path.join(dir, filename)
    else
      ""
    end
  end

  defp find_file(filename) do
    path_env = System.get_env("PATH")
    path_dirs = String.split(path_env || "", ":")
    file_found =
      Enum.flat_map(path_dirs, fn dir ->
        case File.ls(dir) do
          {:ok, files} -> [get_file(files, filename, dir)]
          {:error, _} -> []
        end
      end)
      |> Enum.uniq()
      file_found
  end
end
