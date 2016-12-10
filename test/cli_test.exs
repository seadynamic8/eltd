defmodule CLITest do
  use ExUnit.Case

  import Eltd.CLI, only: [ parse_args: 1, process: 1 ]
  import ExUnit.CaptureIO

  describe "parse_args" do

    test "returns :help with -h or --help flags" do
      assert parse_args(["-h", "anything"]) == :help
      assert parse_args(["--help", "anything"]) == :help
    end

    test "returns {:checkout, branch } with 'checkout <branch> given'" do
      assert parse_args(["checkout", "branch_name"]) == {:checkout, "branch_name"}
    end

    test "returns {:checkout, branch } with 'co <branch> given'" do
      assert parse_args(["co", "branch_name"]) == {:checkout, "branch_name"}
    end

    test "returns {:execute, command } with 'execute <command> given'" do
      assert parse_args(["execute", "command_str"]) == {:execute, "command_str"}
    end

    test "returns {:execute, command } with 'e <command> given'" do
      assert parse_args(["e", "command_str"]) == {:execute, "command_str"}
    end
  end

  describe "process(:help)" do

    test "returns help string" do
      output_string = """
      usage: eltd [checkout | co] <branch>          # Checkout branch concurrently across apps
             eltd [execute | e] "<command string>"  # Execute command concurrently across apps
      """
      function_io_output = capture_io(fn -> process(:help) end)
      assert function_io_output =~ output_string
    end
  end


  describe "process({:execute, command_str})" do

    test "returns to original directory" do
      org_directory = Path.expand("~/Teladoc/admin")
      capture_io(fn -> process({:execute, "git status"}) end)
      assert Path.expand("~/Teladoc/admin") == org_directory
    end
  end
end