# frozen_string_literal: true

require "test_helper"

class TestFormatter < Minitest::Test
  def test_to_unified_diff_empty_details
    result = Diffoscope::Result.new({})
    formatter = Diffoscope::Formatter.new(result)
    assert_equal "", formatter.to_unified_diff
  end

  def test_skip_file_list_details
    result = Diffoscope::Result.new({
      "details" => [{ "source1" => "file list", "source2" => "file list" }]
    })
    formatter = Diffoscope::Formatter.new(result)
    assert_equal "", formatter.to_unified_diff
  end

  def test_skip_zipinfo_details
    result = Diffoscope::Result.new({
      "details" => [{ "source1" => "zipinfo {}", "source2" => "other" }]
    })
    formatter = Diffoscope::Formatter.new(result)
    assert_equal "", formatter.to_unified_diff
  end

  def test_builds_diff_header
    result = Diffoscope::Result.new({
      "details" => [{
        "source1" => "old.txt",
        "source2" => "new.txt",
        "unified_diff" => "@@ -1 +1 @@\n-old\n+new"
      }]
    })
    formatter = Diffoscope::Formatter.new(result)
    output = formatter.to_unified_diff

    assert_includes output, "diff --git a/old.txt b/new.txt"
    assert_includes output, "--- old.txt"
    assert_includes output, "+++ new.txt"
    assert_includes output, "-old"
    assert_includes output, "+new"
  end

  def test_deleted_file_mode
    result = Diffoscope::Result.new({
      "details" => [{
        "source1" => "deleted.txt",
        "source2" => "/dev/null",
        "unified_diff" => "@@ -1 +0,0 @@\n-content"
      }]
    })
    formatter = Diffoscope::Formatter.new(result)
    output = formatter.to_unified_diff

    assert_includes output, "deleted file mode 000000"
  end

  def test_new_file_mode
    result = Diffoscope::Result.new({
      "details" => [{
        "source1" => "/dev/null",
        "source2" => "new.txt",
        "unified_diff" => "@@ -0,0 +1 @@\n+content"
      }]
    })
    formatter = Diffoscope::Formatter.new(result)
    output = formatter.to_unified_diff

    assert_includes output, "new file mode 100644"
  end

  def test_nested_details
    result = Diffoscope::Result.new({
      "details" => [{
        "source1" => "archive.tar.gz",
        "source2" => "archive.tar.gz",
        "details" => [{
          "source1" => "inner.txt",
          "source2" => "inner.txt",
          "unified_diff" => "@@ -1 +1 @@\n-a\n+b"
        }]
      }]
    })
    formatter = Diffoscope::Formatter.new(result)
    output = formatter.to_unified_diff

    assert_includes output, "diff --git a/inner.txt b/inner.txt"
  end
end
