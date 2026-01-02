# frozen_string_literal: true

require "test_helper"

class TestDiffoscope < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Diffoscope::VERSION
  end

  def test_installed_returns_true_when_diffoscope_exists
    Open3.stubs(:capture3).with("which", "diffoscope").returns(["", "", stub(success?: true)])
    assert Diffoscope.installed?
  end

  def test_installed_returns_false_when_diffoscope_missing
    Open3.stubs(:capture3).with("which", "diffoscope").returns(["", "", stub(success?: false)])
    refute Diffoscope.installed?
  end
end
