# -*- encoding : utf-8 -*-

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sugar_utils'
require 'rspec/tabular'
require 'fakefs/spec_helpers'

# Setup code coverage
require 'simplecov'
require 'codeclimate-test-reporter'
SimpleCov.start
CodeClimate::TestReporter.start

SolidAssert.enable_assertions

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end
