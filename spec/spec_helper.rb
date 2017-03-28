# -*- encoding : utf-8 -*-

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sugar_utils'
require 'rspec/tabular'
require 'fakefs/spec_helpers'

# Setup code coverage
require 'simplecov'
SimpleCov.start

SolidAssert.enable_assertions

RSpec.configure do |config|
  # rubocop:disable Style/MixinGrouping
  config.include FakeFS::SpecHelpers, fakefs: true
  # rubocop:enable all
end
