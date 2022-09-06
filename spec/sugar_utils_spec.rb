# frozen_string_literal: true

require 'spec_helper'

describe SugarUtils do
  it 'has a version number' do
    expect(SugarUtils::VERSION).not_to be_nil
  end

  describe '.ensure_boolean' do
    subject { described_class.ensure_boolean(value) }

    inputs  :value
    it_with nil,     false
    it_with false,   false
    it_with true,    true
    it_with 0,       false
    it_with 1,       true
    it_with 2,       true
    it_with 42,      true
    it_with :value,  true
    it_with 'value', true
    it_with 'false', false
    it_with 'FALSE', false
    it_with 'FaLsE', false
    it_with :false,  false # rubocop:disable Lint/BooleanSymbol
    it_with :FALSE,  false
    it_with :FaLsE,  false
  end

  describe '.ensure_integer' do
    subject { described_class.ensure_integer(value) }

    inputs           :value
    raise_error_with 'foobar',           ArgumentError
    raise_error_with Hash[],             TypeError
    raise_error_with Struct.new('Test'), TypeError
    it_with          123,                123
    it_with          123.234,            123
    it_with          '123',              123
    it_with          '123.234',          123
  end

  describe '.scrub_encoding' do
    subject { described_class.scrub_encoding(data, *args) }

    inputs  :data,            :args
    it_with 'foobar',         [],      'foobar'
    it_with 'foobar',         [nil],   'foobar'
    it_with 'foobar',         [111],   'foobar'
    it_with 'foobar',         [''],    'foobar'
    it_with 'foobar',         ['x'],   'foobar'
    it_with 'foobar',         ['xxx'], 'foobar'
    it_with "foo\x92bar\x93", [],      'foobar'
    it_with "foo\x92bar\x93", [nil],   'foobar'
    it_with "foo\x92bar\x93", [111],   'foobar'
    it_with "foo\x92bar\x93", [''],    'foobar'
    it_with "foo\x92bar\x93", ['x'],   'fooxbarx'
    it_with "foo\x92bar\x93", ['xxx'], 'fooxxxbarxxx'
  end
end
