# -*- encoding : utf-8 -*-

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sugar_utils'
require 'simplecov'
require 'rspec/tabular'
require 'fakefs/spec_helpers'
SimpleCov.start 'rails'

SolidAssert.enable_assertions

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end
