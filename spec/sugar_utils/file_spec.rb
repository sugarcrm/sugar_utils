# encoding : utf-8
# frozen_string_literal: true

require 'spec_helper'

describe SugarUtils::File do
  describe '.flock_shared' do
    subject { described_class.flock_shared(file, options) }
    let(:file) { instance_double(File) }
    before do
      allow(Timeout).to receive(:timeout).with(expected_timeout).and_yield
      expect(file).to receive(:flock).with(::File::LOCK_SH)
    end

    inputs            :options,           :expected_timeout
    side_effects_with Hash[],             10
    side_effects_with Hash[timeout: nil], 10
    side_effects_with Hash[timeout: 5],   5
  end

  describe '.flock_exclusive' do
    subject { described_class.flock_exclusive(file, options) }
    let(:file) { instance_double(File) }
    before do
      allow(Timeout).to receive(:timeout).with(expected_timeout).and_yield
      expect(file).to receive(:flock).with(::File::LOCK_EX)
    end

    inputs            :options,           :expected_timeout
    side_effects_with Hash[],             10
    side_effects_with Hash[timeout: nil], 10
    side_effects_with Hash[timeout: 5],   5
  end

  describe '.read', :fakefs do
    subject { described_class.read('filename', options) }

    shared_examples_for 'handles the missing file error' do
      inputs           :options
      raise_error_with Hash[],                                                described_class::Error
      raise_error_with Hash[],                                                'Cannot read filename'
      raise_error_with Hash[raise_on_missing: true],                          described_class::Error
      raise_error_with Hash[raise_on_missing: true],                          'Cannot read filename'
      it_with          Hash[raise_on_missing: false],                         ''
      it_with          Hash[raise_on_missing: false, value_on_missing: 'hi'], 'hi'
    end

    context 'missing file' do
      it_behaves_like 'handles the missing file error'
    end

    context 'with IOError' do
      before { allow(File).to receive(:open).and_raise(IOError) }
      it_behaves_like 'handles the missing file error'
    end

    context 'file present' do
      before { write('filename', "foo\x92bar") }

      context 'and locked' do
        let(:options) { { key: :value } }
        before do
          expect(described_class).to receive(:flock_shared)
            .with(kind_of(File), options)
            .and_raise(Timeout::Error)
        end
        it { expect_raise_error('Cannot read filename because it is locked') }
      end

      context 'and unlocked' do
        let(:options) { { key: :value, scrub_encoding: scrub_encoding } }
        before do
          expect(described_class).to receive(:flock_shared)
            .with(kind_of(File), options)
        end

        inputs  :scrub_encoding
        it_with nil,            "foo\x92bar"
        it_with false,          "foo\x92bar"
        it_with true,           'foobar'
        it_with '',             'foobar'
        it_with 'x',            'fooxbar'
        it_with 'xxx',          'fooxxxbar'
      end
    end
  end

  describe '.read_json', :fakefs do
    subject do
      described_class.read_json(
        :filename, key: :value, value_on_missing: :foobar
      )
    end

    before do
      allow(described_class).to receive(:read)
        .with(:filename, key: :value, value_on_missing: :missing)
        .and_return(file_content)
    end

    inputs           :file_content
    raise_error_with 'I am not json',                described_class::Error
    raise_error_with 'I am not json',                'Cannot parse filename'
    it_with          :missing,                       Hash[]
    it_with          Hash['key' => 'value'].to_json, Hash['key' => 'value']
  end

  describe '.touch', :fakefs do
    subject { described_class.touch(filename, *options) }

    let(:filename) { 'path1/path2/filename' }

    before { subject }

    inputs       :options # rubocop:disable ExtraSpacing, SpaceBeforeFirstArg
    specify_with([])                     { expect(File.exist?(filename)).to eq(true) }
    specify_with([{ owner: 'nobody' }])  { expect(filename).to have_owner('nobody') }
    specify_with([{ group: 'nogroup' }]) { expect(filename).to have_group('nogroup') }
    specify_with([{ mode: 0o600 }])      { expect(filename).to have_file_permission(0o100600) }
    specify_with([{ perm: 0o600 }])      { expect(filename).to have_file_permission(0o100600) }
    specify_with([{ mtime: 0 }])         { expect(filename).to have_mtime(0) }
    specify_with([{ owner: 'nobody', group: 'nogroup', mode: 0o600, mtime: 0 }]) do
      expect(filename).to have_owner('nobody')
      expect(filename).to have_group('nogroup')
      expect(filename).to have_file_permission(0o100600)
      expect(filename).to have_mtime(0)
    end
  end

  describe '.write', :fakefs do
    subject { described_class.write(filename, data, options) }
    let(:data)      { 'content' }
    let(:filename)  { 'dir1/dir2/filename' }

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
      before do
        expect(described_class).to receive(:flock_exclusive)
          .with(kind_of(File), options)
          .and_raise(Timeout::Error)
      end
      it { expect_raise_error("Unable to write #{filename} because it is locked") }
    end

    context 'unlocked' do
      shared_examples_for 'file is written' do
        before do
          expect(described_class).to receive(:flock_exclusive)
            .with(kind_of(File), options)
        end

        context 'default options' do
          let(:options) { {} }
          before { subject }
          specify { expect(filename).to have_content(data) }
          specify { expect(filename).to have_file_permission(0o100644) }
        end

        context 'with deprecated options' do
          let(:options) { { mode: 0o600 } }
          before { subject }
          specify { expect(filename).to have_content(data) }
          specify { expect(filename).to have_file_permission(0o100600) }
        end

        context 'without deprecated options' do
          let(:options) do
            { flush: true, owner: 'nobody', group: 'nogroup', mode: 'w', perm: 0o600 }
          end
          before do
            expect_any_instance_of(File).to receive(:flush)
            expect_any_instance_of(File).to receive(:fsync)
            subject
          end
          specify { expect(filename).to have_content(data) }
          specify { expect(filename).to have_owner('nobody') }
          specify { expect(filename).to have_group('nogroup') }
          specify { expect(filename).to have_file_permission(0o100600) }
        end
      end

      context 'and not exist' do
        it_behaves_like 'file is written'
      end

      context 'and exists' do
        before { write(filename, 'foobar', 0o777) }
        context 'not locked' do
          it_behaves_like 'file is written'

          context 'with append mode' do
            let(:options) { { mode: 'a+' } }
            before do
              expect(described_class).to receive(:flock_exclusive)
                .with(kind_of(File), options)
              subject
            end
            specify { expect(filename).to have_content("foobar#{data}") }
          end
        end
      end
    end
  end

  describe '.write_json', :fakefs do
    subject { described_class.write_json(:filename, data, :options) }

    let(:data) { { 'key' => 'value' } }
    before do
      expect(described_class).to receive(:write).with(
        :filename, MultiJson.dump(data, pretty: true), :options
      )
    end

    specify { subject }
  end

  ##############################################################################

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
