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

  describe '.read_json', :fakefs do
    subject { described_class.read_json('filename.json', options) }

    context 'missing file' do
      inputs           :options
      raise_error_with Hash[],                        described_class::Error
      raise_error_with Hash[],                        'Cannot read filename.json'
      raise_error_with Hash[raise_on_missing: true],  described_class::Error
      raise_error_with Hash[raise_on_missing: true],  'Cannot read filename.json'
      it_with          Hash[raise_on_missing: false], {}
    end

    context 'file present' do
      let(:options) { {} }

      before { File.open('filename.json', 'w+') { |f| f.write(json_content) } }

      context 'and locked' do
        let(:json_content) { nil }
        before do
          expect(described_class).to receive(:flock)
            .with(kind_of(File), File::LOCK_SH, options)
            .and_raise(Timeout::Error)
        end
        it do
          expect { subject }.to raise_error(described_class::Error, 'Cannot read filename.json because it is locked')
        end
      end

      context 'and unlocked' do
        before do
          expect(described_class).to receive(:flock).with(
            kind_of(File), File::LOCK_SH, options
          )
        end

        inputs           :json_content
        raise_error_with 'I am not json',                described_class::Error
        raise_error_with 'I am not json',                'Cannot parse filename.json'
        it_with          Hash['key' => 'value'].to_json, Hash['key' => 'value']
      end
    end
  end
end
