# frozen_string_literal: true

require "test_helper"

class TestResult < Minitest::Test
  def test_identical_when_empty_data
    result = Diffoscope::Result.new({})
    assert result.identical?
  end

  def test_identical_when_no_details
    result = Diffoscope::Result.new({ "source1" => "a", "source2" => "b" })
    assert result.identical?
  end

  def test_not_identical_when_details_present
    result = Diffoscope::Result.new({ "details" => [{ "source1" => "a" }] })
    refute result.identical?
  end

  def test_source1_from_data
    result = Diffoscope::Result.new({ "source1" => "file1.txt" })
    assert_equal "file1.txt", result.source1
  end

  def test_source1_override
    result = Diffoscope::Result.new({ "source1" => "file1.txt" }, source1: "override.txt")
    assert_equal "override.txt", result.source1
  end

  def test_details_returns_empty_array_when_nil
    result = Diffoscope::Result.new({})
    assert_equal [], result.details
  end

  def test_details_returns_details_array
    details = [{ "source1" => "a", "source2" => "b" }]
    result = Diffoscope::Result.new({ "details" => details })
    assert_equal details, result.details
  end

  def test_to_h_returns_data
    data = { "source1" => "a", "source2" => "b" }
    result = Diffoscope::Result.new(data)
    assert_equal data, result.to_h
  end

  def test_sha256_accessors
    result = Diffoscope::Result.new({}, sha256_1: "abc123", sha256_2: "def456")
    assert_equal "abc123", result.sha256_1
    assert_equal "def456", result.sha256_2
  end
end
