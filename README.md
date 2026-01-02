# Diffoscope

[![Gem Version](https://badge.fury.io/rb/diffoscope.svg)](https://rubygems.org/gems/diffoscope)

Ruby bindings for [diffoscope](https://diffoscope.org/), a tool for in-depth comparison of files, archives, and directories.

## Installation

Requires [diffoscope](https://diffoscope.org/) to be installed. See their website for installation options (pip, apt, brew, etc).

Then install the gem:

```bash
gem install diffoscope
```

Or add to your Gemfile:

```ruby
gem 'diffoscope'
```

### Docker

To avoid installing diffoscope locally:

```bash
docker build -t diffoscope .

# Compare URLs
docker run --rm diffoscope https://example.com/file1.tar.gz https://example.com/file2.tar.gz

# Compare local files (mount current directory)
docker run --rm -v "$(pwd):/data" -w /data diffoscope file1.tar.gz file2.tar.gz
```

## Usage

### Ruby API

```ruby
require 'diffoscope'

# Compare local files
result = Diffoscope.compare("old.tar.gz", "new.tar.gz")

# Compare URLs
result = Diffoscope.compare("https://example.com/pkg-1.0.tar.gz", "https://example.com/pkg-1.1.tar.gz")

# Compare package URLs
result = Diffoscope.compare("pkg:gem/rails@7.0.0", "pkg:gem/rails@7.1.0")

# Check results
result.identical?        # => true/false
result.to_unified_diff   # => git-style diff string
result.to_h              # => raw diffoscope hash
result.sha256_1          # => SHA256 of first file
result.sha256_2          # => SHA256 of second file
```

### CLI

```bash
diffoscope old.tar.gz new.tar.gz
diffoscope --json old.tar.gz new.tar.gz
diffoscope pkg:gem/rails@7.0.0 pkg:gem/rails@7.1.0
diffoscope --check  # verify diffoscope is installed
```

## License

GPL-3.0-or-later
