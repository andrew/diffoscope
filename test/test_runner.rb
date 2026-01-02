# frozen_string_literal: true

require "test_helper"

class TestRunner < Minitest::Test
  def setup
    @runner = Diffoscope::Runner.new("file1.txt", "file2.txt")
  end

  def test_build_command_basic
    expected = ["diffoscope", "file1.txt", "file2.txt", "--json", "-"]
    assert_equal expected, @runner.build_command
  end

  def test_build_command_with_new_file
    runner = Diffoscope::Runner.new("a", "b", new_file: true)
    assert_includes runner.build_command, "--new-file"
  end

  def test_build_command_with_max_diff_block_lines
    runner = Diffoscope::Runner.new("a", "b", max_diff_block_lines: 500)
    cmd = runner.build_command
    assert_includes cmd, "--max-diff-block-lines"
    assert_includes cmd, "500"
  end

  def test_run_returns_identical_result_for_empty_output
    Open3.stubs(:capture3).with("which", "diffoscope").returns(["", "", stub(success?: true)])
    Open3.stubs(:capture3).with(*@runner.build_command).returns(["", "", stub(success?: true)])

    result = @runner.run
    assert result.identical?
  end

  def test_run_parses_json_output
    json_output = '{"source1": "file1.txt", "source2": "file2.txt", "details": []}'
    Open3.stubs(:capture3).with("which", "diffoscope").returns(["", "", stub(success?: true)])
    Open3.stubs(:capture3).with(*@runner.build_command).returns([json_output, "", stub(success?: true)])

    result = @runner.run
    assert_equal "file1.txt", result.to_h["source1"]
  end

  def test_run_raises_not_installed_error
    Open3.stubs(:capture3).with("which", "diffoscope").returns(["", "", stub(success?: false)])

    assert_raises(Diffoscope::NotInstalledError) { @runner.run }
  end

  def test_run_raises_execution_error_on_invalid_json
    Open3.stubs(:capture3).with("which", "diffoscope").returns(["", "", stub(success?: true)])
    Open3.stubs(:capture3).with(*@runner.build_command).returns(["not valid json", "error", stub(success?: false)])

    assert_raises(Diffoscope::ExecutionError) { @runner.run }
  end

  def test_installed_class_method
    Open3.stubs(:capture3).with("which", "diffoscope").returns(["", "", stub(success?: true)])
    assert Diffoscope::Runner.installed?
  end
end
