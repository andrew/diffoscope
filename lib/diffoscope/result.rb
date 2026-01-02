# frozen_string_literal: true

module Diffoscope
  class Result
    attr_reader :data, :source1, :source2, :sha256_1, :sha256_2

    def initialize(data, source1: nil, source2: nil, sha256_1: nil, sha256_2: nil)
      @data = data
      @source1 = source1 || data["source1"]
      @source2 = source2 || data["source2"]
      @sha256_1 = sha256_1
      @sha256_2 = sha256_2
    end

    def identical?
      data.empty? || data["details"].nil?
    end

    def details
      data["details"] || []
    end

    def to_h
      data
    end

    def to_json(*args)
      data.to_json(*args)
    end

    def to_unified_diff
      Formatter.new(self).to_unified_diff
    end
  end
end
