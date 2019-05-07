# frozen_string_literal: true

require 'aruba/cucumber'

# @see spec/spec_helper.rb
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
