# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'fileutils'

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
      before { write('filename.json', content) }

      context 'SysteCallError' do
        let(:options) { {} }
        let(:content) { '' }
        let(:exception) { SystemCallError.new(nil) }
        before { allow(File).to receive(:open).and_raise(exception) }
        it { expect_raise_error('Cannot read filename.json') }
      end

      context 'IOError' do
        let(:options) { {} }
        let(:content) { '' }
        let(:exception) { IOError.new(nil) }
        before { allow(File).to receive(:open).and_raise(exception) }
        it { expect_raise_error('Cannot read filename.json') }
      end

      context 'and locked' do
        let(:content) { '' }
        before { expect_flock(File::LOCK_SH, options).and_raise(Timeout::Error) }
        it { expect_raise_error('Cannot read filename.json because it is locked') }
      end

      context 'and unlocked' do
        before { expect_flock(File::LOCK_SH, options) }

        inputs           :content
        raise_error_with 'I am not json',                described_class::Error
        raise_error_with 'I am not json',                'Cannot parse filename.json'
        it_with          Hash['key' => 'value'].to_json, Hash['key' => 'value']
      end
    end
  end

  describe '.write_json', :fakefs do
    subject { described_class.write_json(filename, data, options) }
    let(:data)     { { 'key' => 'value' } }
    let(:filename) { 'dir1/dir2/filename.json' }

    context 'SystemCallError' do
      let(:options) { {} }
      let(:exception) { SystemCallError.new(nil) }
      before { allow(File).to receive(:open).and_raise(exception) }
      it { expect_raise_error("Unable to write #{filename} with #{exception}") }
    end

    context 'IOError' do
      let(:options) { {} }
      let(:exception) { IOError.new(nil) }
      before { allow(File).to receive(:open).and_raise(exception) }
      it { expect_raise_error("Unable to write #{filename} with #{exception}") }
    end

    context 'locked' do
      let(:options) { {} }
      before { expect_flock(File::LOCK_EX, options).and_raise(Timeout::Error) }
      it { expect_raise_error("Unable to write #{filename} because it is locked") }
    end

    context 'unlocked' do
      shared_examples_for 'file is written' do
        before { expect_flock(File::LOCK_EX, options) }

        context 'default options' do
          let(:options) { {} }
          before { subject }
          specify do
            expect(File.exist?(filename)).to eq(true)
            expect(MultiJson.load(File.read(filename))).to eq(data)
            expect(sprintf('%o', File.stat(filename).mode)).to eq('100666')
          end
        end

        context 'options' do
          let(:options) { { flush: true, perm: 0600 } }
          before do
            expect_any_instance_of(File).to receive(:flush)
            expect_any_instance_of(File).to receive(:fsync)
            subject
          end
          specify do
            expect(File.exist?(filename)).to eq(true)
            expect(MultiJson.load(File.read(filename))).to eq(data)
            expect(sprintf('%o', File.stat(filename).mode)).to eq('100600')
          end
        end
      end

      context 'and not exist' do
        it_behaves_like 'file is written'
      end

      context 'and exists' do
        before { write(filename, 'foobar', 0777) }
        context 'not locked' do
          it_behaves_like 'file is written'
        end
      end
    end
  end

  ##############################################################################

  # @param [File::LOCK_SH, File::LOCK_EX] locking_constant
  # @param [Hash] options
  def expect_flock(locking_constant, options)
    expect(described_class).to receive(:flock)
      .with(kind_of(File), locking_constant, options)
  end

  # @param [String] message
  def expect_raise_error(message)
    expect { subject }.to raise_error(described_class::Error, message)
  end

  # @overload write(filename, content)
  #   @param [String] filename
  #   @param [String] content
  #
  # @overload write(filename, content, perm)
  #   @param [String] filename
  #   @param [String] content
  #   @param [Integer] perm
  #
  # @return [void]
  def write(filename, content, perm = nil)
    FileUtils.mkdir_p(::File.dirname(filename))
    File.write(filename, content)
    FileUtils.chmod(perm, filename) if perm
  end


end
