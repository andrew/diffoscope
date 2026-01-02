# frozen_string_literal: true

require "tempfile"
require "fileutils"
require "digest"
require "typhoeus"
require "purl"

module Diffoscope
  class Resolver
    attr_reader :input, :temp_dir
    attr_accessor :sha256

    def initialize(input, temp_dir:)
      @input = input
      @temp_dir = temp_dir
      @sha256 = nil
    end

    def resolve
      case input_type
      when :file
        resolve_file
      when :url
        resolve_url
      when :purl
        resolve_purl
      end
    end

    def input_type
      if File.exist?(input)
        :file
      elsif input.start_with?("pkg:")
        :purl
      elsif input.match?(%r{\Ahttps?://})
        :url
      else
        raise ArgumentError, "Cannot determine input type for: #{input}"
      end
    end

    def resolve_file
      @sha256 = Digest::SHA256.hexdigest(File.read(input))
      input
    end

    def resolve_url
      download_to_temp(input)
    end

    def resolve_purl
      purl = Purl.parse(input)
      download_url = purl.download_url
      raise ResolverError, "Cannot resolve download URL for: #{input}" if download_url.nil?
      download_to_temp(download_url)
    end

    def download_to_temp(url)
      filename = File.basename(URI.parse(url).path)
      filename = "download" if filename.empty?
      path = File.join(temp_dir, filename)

      downloaded_file = File.open(path, "wb")
      request = Typhoeus::Request.new(url, followlocation: true)

      request.on_headers do |response|
        raise DownloadError, "Failed to download #{url}: HTTP #{response.code}" if response.code != 200
      end

      request.on_body { |chunk| downloaded_file.write(chunk) }
      request.on_complete { downloaded_file.close }
      request.run

      @sha256 = Digest::SHA256.hexdigest(File.read(path))
      path
    end
  end
end
