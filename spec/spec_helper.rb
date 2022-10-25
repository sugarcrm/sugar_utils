# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'rspec/tabular'
require 'fakefs/spec_helpers'
require 'rspec/side_effects'
require 'etc'

# Setup code coverage
require 'simplecov'
require 'simplecov-lcov'
require 'simplecov_json_formatter'
SimpleCov.start do
  # NOTE: Include the lcov formatter for CodeClimate reporting.
  # Even though the simplecov JSON format will be output and used by default,
  # the test reporter does not handle it reliable.
  # Using the lcov formatter is more reliable.
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::JSONFormatter,
      SimpleCov::Formatter::LcovFormatter
    ]
  )
end

require 'sugar_utils'
MultiJson.use(:ok_json)

SolidAssert.enable_assertions

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end

RSpec::Matchers.define :have_json_content do |expected|
  match do |actual|
    next false unless File.exist?(actual)

    @actual = MultiJson.load(File.read(actual))
    values_match?(expected, @actual)
  end

  diffable
end

RSpec::Matchers.define :have_content do |expected|
  match do |actual|
    next false unless File.exist?(actual)

    @actual = File.open(actual, 'r') { |f| f.read.chomp }
    values_match?(expected, @actual)
  end

  diffable
end

RSpec::Matchers.define :have_file_permission do |expected|
  match do |actual|
    next false unless File.exist?(actual)

    @actual   = format('%<mode>o', mode: File.stat(actual).mode)
    @expected = format('%<mode>o', mode: expected)
    values_match?(@expected, @actual)
  end
end

RSpec::Matchers.define :have_owner do |expected|
  match do |actual|
    next false unless File.exist?(actual)

    @actual   = Etc.getpwuid(File.stat(filename).uid).name
    @expected = expected
    values_match?(@expected, @actual)
  end
end

RSpec::Matchers.define :have_group do |expected|
  match do |actual|
    next false unless File.exist?(actual)

    @actual   = Etc.getgrgid(File.stat(actual).gid).name
    @expected = expected
    values_match?(@expected, @actual)
  end
end

RSpec::Matchers.define :have_mtime do |expected|
  match do |actual|
    next false unless File.exist?(actual)

    @actual   = File.stat(actual).mtime.to_i
    @expected = expected
    values_match?(@expected, @actual)
  end
end
