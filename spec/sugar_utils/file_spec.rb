# -*- encoding : utf-8 -*-

require 'spec_helper'

describe SugarUtils::File do
  describe '.flock' do
    subject { described_class.flock(file, :locking_constant, options) }
    let(:file) { instance_double(File) }
    before do
      expect(Timeout).to receive(:timeout).with(expected_timeout).and_yield
      expect(file).to receive(:flock).with(:locking_constant)
    end

    inputs            :options,           :expected_timeout
    side_effects_with Hash[],             10
    side_effects_with Hash[timeout: nil], 10
    side_effects_with Hash[timeout: 5],   5
  end
end
