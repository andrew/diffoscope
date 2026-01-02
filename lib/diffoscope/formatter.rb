# frozen_string_literal: true

module Diffoscope
  class Formatter
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def to_unified_diff
      result.details.map { |detail| format_detail(detail) }.join("\n")
    end

    def format_detail(detail)
      if detail["details"]
        detail["details"].map { |subdetail| unwrap_detail(subdetail) }.join("\n")
      else
        unwrap_detail(detail)
      end
    end

    def unwrap_detail(detail)
      return "" if skip_detail?(detail)

      lines = extract_lines(detail)
      return "" if lines.nil?

      build_diff_header(detail, lines)
    end

    def skip_detail?(detail)
      ["file list", "zipinfo {}", "zipinfo /dev/stdin"].include?(detail["source1"])
    end

    def extract_lines(detail)
      if detail["unified_diff"] && !detail["unified_diff"].empty?
        detail["unified_diff"]
      elsif detail["details"]&.first
        detail["details"].first["unified_diff"]
      end
    end

    def build_diff_header(detail, lines)
      source1 = detail["source1"]
      source2 = detail["source2"]

      header = "diff --git a/#{source1} b/#{source2}\n"
      header += "deleted file mode 000000\n" if source2 == "/dev/null"
      header += "new file mode 100644\n" if source1 == "/dev/null"
      header += "index 0000001..0ddf2ba\n"
      header += "--- #{source1}\n"
      header += "+++ #{source2}\n"
      header += lines.to_s
      header
    end
  end
end
