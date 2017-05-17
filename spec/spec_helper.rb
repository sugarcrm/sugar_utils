# -*- encoding : utf-8 -*-

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sugar_utils'
require 'rspec/tabular'
require 'fakefs/spec_helpers'
# HACK: including pp seems to resolve an error with FakeFS and File.read
# This seems to be related to but not the same as the problem mentioned in the
# README
# https://github.com/fakefs/fakefs#fakefs-vs-pp-----typeerror-superclass-mismatch-for-class-file
require 'pp'

# Setup code coverage
require 'simplecov'
SimpleCov.start

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

    @actual   = format('%o', File.stat(filename).mode)
    @expected = format('%o', expected)
    values_match?(@expected, @actual)
  end
end
