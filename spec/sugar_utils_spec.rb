# -*- encoding : utf-8 -*-

require 'spec_helper'

describe SugarUtils do
  it 'has a version number' do
    expect(SugarUtils::VERSION).not_to be nil
  end

  describe '.ensure_boolean' do
    subject { described_class.ensure_boolean(value) }

    inputs  :value
    it_with nil,     false
    it_with false,   false
    it_with true,    true
    it_with :value,  true
    it_with 'value', true
    it_with 'false', false
    it_with 'FALSE', false
    it_with 'FaLsE', false
    it_with :false,  false
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
end
