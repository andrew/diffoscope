# frozen_string_literal: true

require "test_helper"

class TestResolver < Minitest::Test
  def test_input_type_file
    File.stubs(:exist?).with("/path/to/file.txt").returns(true)
    resolver = Diffoscope::Resolver.new("/path/to/file.txt", temp_dir: "/tmp")
    assert_equal :file, resolver.input_type
  end

  def test_input_type_url_https
    File.stubs(:exist?).returns(false)
    resolver = Diffoscope::Resolver.new("https://example.com/file.tar.gz", temp_dir: "/tmp")
    assert_equal :url, resolver.input_type
  end

  def test_input_type_url_http
    File.stubs(:exist?).returns(false)
    resolver = Diffoscope::Resolver.new("http://example.com/file.tar.gz", temp_dir: "/tmp")
    assert_equal :url, resolver.input_type
  end

  def test_input_type_purl
    File.stubs(:exist?).returns(false)
    resolver = Diffoscope::Resolver.new("pkg:gem/rails@7.0.0", temp_dir: "/tmp")
    assert_equal :purl, resolver.input_type
  end

  def test_input_type_raises_for_unknown
    File.stubs(:exist?).returns(false)
    resolver = Diffoscope::Resolver.new("something-weird", temp_dir: "/tmp")
    assert_raises(ArgumentError) { resolver.input_type }
  end

  def test_resolve_file_returns_path_and_sets_sha256
    Dir.mktmpdir do |dir|
      path = File.join(dir, "test.txt")
      File.write(path, "hello world")

      resolver = Diffoscope::Resolver.new(path, temp_dir: dir)
      result = resolver.resolve

      assert_equal path, result
      assert_equal Digest::SHA256.hexdigest("hello world"), resolver.sha256
    end
  end

  def test_resolve_url_downloads_file
    stub_request(:get, "https://example.com/file.txt")
      .to_return(status: 200, body: "content here")

    Dir.mktmpdir do |dir|
      resolver = Diffoscope::Resolver.new("https://example.com/file.txt", temp_dir: dir)
      path = resolver.resolve

      assert File.exist?(path)
      assert_equal "content here", File.read(path)
      assert_equal Digest::SHA256.hexdigest("content here"), resolver.sha256
    end
  end

  def test_resolve_url_raises_on_non_200
    stub_request(:get, "https://example.com/missing.txt")
      .to_return(status: 404)

    Dir.mktmpdir do |dir|
      resolver = Diffoscope::Resolver.new("https://example.com/missing.txt", temp_dir: dir)
      assert_raises(Diffoscope::DownloadError) { resolver.resolve }
    end
  end
end
