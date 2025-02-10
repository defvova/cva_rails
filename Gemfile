# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in cva_rails.gemspec
gemspec

gem "actionpack", ">= 6.1"

if ENV["ACTIONVIEW_VERSION"]
  gem "actionview", "~> #{ENV["ACTIONVIEW_VERSION"]}.0"
else
  gem "actionview"
end

gem "rake", "~> 13.0"

gem "minitest", "~> 5.16"

gem "rubocop", "~> 1.21"
gem "rubocop-minitest", require: false
gem "rubocop-rake", require: false

gem "simplecov", "~> 0.22.0", require: false
gem "simplecov-cobertura", "~> 2.1", require: false

gem "benchmark-ips", "~> 2.14"
