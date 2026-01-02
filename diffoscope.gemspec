# frozen_string_literal: true

require_relative "lib/diffoscope/version"

Gem::Specification.new do |spec|
  spec.name = "diffoscope"
  spec.version = Diffoscope::VERSION
  spec.authors = ["Andrew Nesbitt"]
  spec.email = ["andrewnez@gmail.com"]

  spec.summary = "Ruby bindings for diffoscope"
  spec.description = "Compare files, URLs, or package URLs using diffoscope"
  spec.homepage = "https://github.com/andrew/diffoscope"
  spec.license = "GPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "purl", ">= 1.7.0"
  spec.add_dependency "typhoeus"
end
