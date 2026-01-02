# frozen_string_literal: true

require_relative "diffoscope/version"
require_relative "diffoscope/result"
require_relative "diffoscope/formatter"
require_relative "diffoscope/runner"
require_relative "diffoscope/resolver"

module Diffoscope
  class Error < StandardError; end
  class NotInstalledError < Error; end
  class ExecutionError < Error; end
  class DownloadError < Error; end
  class ResolverError < Error; end

  def self.compare(input1, input2, **options)
    Dir.mktmpdir do |temp_dir|
      resolver1 = Resolver.new(input1, temp_dir: temp_dir)
      resolver2 = Resolver.new(input2, temp_dir: temp_dir)

      path1 = resolver1.resolve
      path2 = resolver2.resolve

      result = Runner.new(path1, path2, options).run
      result.instance_variable_set(:@sha256_1, resolver1.sha256)
      result.instance_variable_set(:@sha256_2, resolver2.sha256)
      result.instance_variable_set(:@source1, input1)
      result.instance_variable_set(:@source2, input2)
      result
    end
  end

  def self.installed?
    Runner.installed?
  end
end
