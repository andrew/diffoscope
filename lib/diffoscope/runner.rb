# frozen_string_literal: true

require "open3"
require "json"
require "tempfile"

module Diffoscope
  class Runner
    attr_reader :path1, :path2, :options

    def initialize(path1, path2, options = {})
      @path1 = path1
      @path2 = path2
      @options = options
    end

    def run
      check_diffoscope_installed!

      stdout, stderr, status = Open3.capture3(*build_command)

      if stdout.empty? && status.success?
        Result.new({}, source1: path1, source2: path2)
      else
        begin
          data = JSON.parse(stdout)
          Result.new(data, source1: path1, source2: path2)
        rescue JSON::ParserError => e
          raise ExecutionError, "Failed to parse diffoscope output: #{e.message}\nStderr: #{stderr}"
        end
      end
    end

    def build_command
      cmd = ["diffoscope", path1, path2, "--json", "-"]
      cmd += ["--new-file"] if options[:new_file]
      cmd += ["--max-diff-block-lines", options[:max_diff_block_lines].to_s] if options[:max_diff_block_lines]
      cmd
    end

    def check_diffoscope_installed!
      _, _, status = Open3.capture3("which", "diffoscope")
      raise NotInstalledError, "diffoscope is not installed. See https://diffoscope.org for installation options." unless status.success?
    end

    def self.installed?
      _, _, status = Open3.capture3("which", "diffoscope")
      status.success?
    end
  end
end
