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

    context 'when missing file' do
      it_behaves_like 'handles the missing file error'
    end

    context 'with IOError' do
      before { allow(File).to receive(:open).and_raise(IOError) }

      it_behaves_like 'handles the missing file error'
    end

    context 'when file present' do
      before { write('filename', "foo\x92bar") }

      # rubocop:disable RSpec/NestedGroups
      context 'when locked' do
        let(:options) { { key: :value } }

        before do
          expect(described_class).to receive(:flock_shared)
            .with(kind_of(File), options)
            .and_raise(Timeout::Error)
        end

        it { expect_raise_error('Cannot read filename because it is locked') }
      end

      context 'when unlocked' do
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
      # rubocop:enable RSpec/NestedGroups
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

    inputs            :options # rubocop:disable ExtraSpacing, SpaceBeforeFirstArg
    side_effects_with([])                     { expect(File.exist?(filename)).to eq(true) }
    side_effects_with([{ owner: 'nobody' }])  { expect(filename).to have_owner('nobody') }
    side_effects_with([{ group: 'nogroup' }]) { expect(filename).to have_group('nogroup') }
    side_effects_with([{ mode: 0o600 }])      { expect(filename).to have_file_permission(0o100600) }
    side_effects_with([{ perm: 0o600 }])      { expect(filename).to have_file_permission(0o100600) }
    side_effects_with([{ mtime: 0 }])         { expect(filename).to have_mtime(0) }
    side_effects_with([{ owner: 'nobody', group: 'nogroup', mode: 0o600, mtime: 0 }]) do
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

    context 'when SystemCallError' do
      let(:options) { {} }
      let(:exception) { SystemCallError.new(nil) }

      before { allow(File).to receive(:open).and_raise(exception) }

      it { expect_raise_error("Unable to write #{filename} with #{exception}") }
    end

    context 'when IOError' do
      let(:options) { {} }
      let(:exception) { IOError.new(nil) }

      before { allow(File).to receive(:open).and_raise(exception) }

      it { expect_raise_error("Unable to write #{filename} with #{exception}") }
    end

    context 'when locked' do
      let(:options) { {} }

      before do
        expect(described_class).to receive(:flock_exclusive)
          .with(kind_of(File), options)
          .and_raise(Timeout::Error)
      end

      it { expect_raise_error("Unable to write #{filename} because it is locked") }
    end

    context 'when unlocked' do
      shared_examples_for 'file is written' do # rubocop:disable RSpec/SharedContext
        before do
          expect(described_class).to receive(:flock_exclusive)
            .with(kind_of(File), options)
        end

        # rubocop:disable RSpec/NestedGroups
        context 'without options' do
          let(:options) { {} }

          its_side_effects_are do
            expect(filename).to have_content(data)
            expect(filename).to have_file_permission(0o100644)
          end
        end

        context 'with deprecated options' do
          let(:options) { { mode: 0o600 } }

          its_side_effects_are do
            expect(filename).to have_content(data)
            expect(filename).to have_file_permission(0o100600)
          end
        end

        context 'without deprecated options' do
          let(:options) do
            { flush: true, owner: 'nobody', group: 'nogroup', mode: 'w', perm: 0o600 }
          end

          before do
            # rubocop:disable RSpec/AnyInstance
            expect_any_instance_of(File).to receive(:flush)
            expect_any_instance_of(File).to receive(:fsync)
            # rubocop:enable RSpec/AnyInstance
          end

          its_side_effects_are do
            expect(filename).to have_content(data)
            expect(filename).to have_owner('nobody')
            expect(filename).to have_group('nogroup')
            expect(filename).to have_file_permission(0o100600)
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when file does not exist' do
        it_behaves_like 'file is written'
      end

      context 'when file exists' do
        before { write(filename, 'foobar', 0o777) }

        context 'when not locked' do
          it_behaves_like 'file is written'

          context 'with append mode' do
            let(:options) { { mode: 'a+' } }

            before do
              expect(described_class).to receive(:flock_exclusive)
                .with(kind_of(File), options)
            end

            its_side_effects_are { expect(filename).to have_content("foobar#{data}") }
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups
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

    it_has_side_effects
  end

  ##############################################################################

  # @param message [String]
  def expect_raise_error(message)
    expect { subject }.to raise_error(described_class::Error, message)
  end

  # @overload write(filename, content)
  #   @param filename [String]
  #   @param content [String]
  #
  # @overload write(filename, content, perm)
  #   @param filename [String]
  #   @param content [String]
  #   @param perm [Integer]
  #
  # @return [void]
  def write(filename, content, perm = nil)
    FileUtils.mkdir_p(::File.dirname(filename))
    File.write(filename, content)
    FileUtils.chmod(perm, filename) if perm
  end
end
