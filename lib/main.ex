defmodule CLI do
  import Bitwise
  @commands ["exit", "echo", "type", "pwd", "cd"]

  def main(_args) do
    pwd = File.cwd!()
    loop(pwd)
  end

  defp loop(pwd) do
    IO.write("$ ")
    command = IO.gets("") |> String.trim()
    new_pwd = evaluate(command, pwd)
    loop(new_pwd)
  end

  def evaluate("exit", _pwd) do
    exit(:normal)
  end

  def evaluate("echo "<> cmd, pwd) do
    IO.puts(cmd)
    pwd
  end

  def evaluate("type "<> cmd, pwd) do
    if Enum.member?(@commands, cmd) do
      IO.puts("#{cmd} is a shell builtin")
    else
      case find_file(cmd) do
        [] -> IO.puts("#{cmd}: not found")
        file -> IO.puts("#{cmd} is #{file}")
      end

    end
    pwd
  end

  def evaluate("pwd", pwd) do
    IO.puts(pwd)
    pwd
  end

  def evaluate("cd ..", pwd) do
    Path.dirname(pwd)
  end

  def evaluate("cd "<> path, pwd) do
    new_path = if String.starts_with?(path, "/") do
      path
    else
      Path.join(pwd, path)
    end

    case File.dir?(new_path) do
      true -> new_path
      false ->
        IO.puts("cd: #{path}: No such file or directory")
        pwd
    end
  end

  def evaluate(cmd, pwd) do
    [command | args] = String.split(cmd, " ")

    executable = find_file(command)
    if length(executable) > 0 do
      run_external_command(command, args)
    else
      IO.puts("#{cmd}: command not found")
    end
    pwd
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
    {_output, _exit_status} = System.cmd(filepath,args,into: IO.stream(),arg0: filepath)
  end
end
