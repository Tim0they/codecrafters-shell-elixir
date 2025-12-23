defmodule CLI do
  import Bitwise
  @commands ["exit", "echo", "type"]

  def main(args) do
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
        [] -> IO.puts("#{cmd}: not found")
        file -> IO.puts("#{cmd} is #{file}")
      end

    end
  end

  def evaluate(cmd) do
    [command | args] = String.split(cmd, " ")

    executable = find_file(command)
    if length(executable) > 0 do
      run_external_command(command, args)
    else
      IO.puts("#{cmd}: command not found")
    end
  end



  defp get_file(files, filename, dir) do
    if Enum.member?(files, filename) do
      Path.join(dir, filename)
    else
      ""
    end
  end

  defp is_executable(filepath) do
    case File.stat(filepath) do
      {:ok, stat} -> (stat.mode &&& 0o111) != 0
      {:error, _} -> false
    end
  end

  defp find_file(filename) do
    path_env = System.get_env("PATH")
    path_dirs = String.split(path_env || "", ":")
    files_found =
      Enum.flat_map(path_dirs, fn dir ->
        case File.ls(dir) do
          {:ok, files} -> [get_file(files, filename, dir)]
          {:error, _} -> []
        end
      end)
      |> Enum.uniq()
      |> Enum.filter(&is_executable/1)
      |> Enum.take(1)
      files_found
  end

  def run_external_command(filepath, args\\[]) do
    {_output, _exit_status} = System.cmd(filepath,args,into: IO.stream())
  end
end
