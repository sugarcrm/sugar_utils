# frozen_string_literal: true

require 'spec_helper'

describe SugarUtils::File::WriteOptions do
  subject(:write_options) { described_class.new(filename, options) }

  let(:filename) { nil }

  before do
    allow(File).to receive(:exist?).with('missing').and_return(false)
    allow(File).to receive(:exist?).with('found').and_return(true)
    allow(File::Stat).to receive(:new).with('found').and_return(
      instance_double(File::Stat, uid: :uid, gid: :gid)
    )
  end

  describe '#flush?' do
    subject { write_options.flush? }

    inputs  :options
    it_with Hash[],              false
    it_with Hash[flush: :flush], :flush
  end

  describe '#perm' do
    subject { write_options.perm(*args) }

    inputs  :options, :args
    it_with Hash[],                         [],                0o644
    it_with Hash[],                         %i[default_value], :default_value
    it_with Hash[mode: :mode],              [],                :mode
    it_with Hash[mode: :mode],              %i[default_value], :mode
    it_with Hash[perm: :perm, mode: :mode], [],                :mode
    it_with Hash[perm: :perm, mode: :mode], %i[default_value], :mode
    it_with Hash[perm: :perm],              [],                :perm
    it_with Hash[perm: :perm],              %i[default_value], :perm
  end

  describe '#owner' do
    subject { write_options.owner }

    inputs  :filename, :options
    it_with nil,       Hash[],              nil
    it_with 'missing', Hash[],              nil
    it_with 'found',   Hash[],              :uid
    it_with nil,       Hash[owner: :owner], :owner
    it_with 'missing', Hash[owner: :owner], :owner
    it_with 'found',   Hash[owner: :owner], :owner
  end

  describe '#group' do
    subject { write_options.group }

    inputs  :filename, :options
    it_with nil,       Hash[],              nil
    it_with 'missing', Hash[],              nil
    it_with 'found',   Hash[],              :gid
    it_with nil,       Hash[group: :group], :group
    it_with 'missing', Hash[group: :group], :group
    it_with 'found',   Hash[group: :group], :group
  end

  describe '#slice' do
    subject { write_options.slice(*args) }

    let(:options) { { key1: :value1, key2: :value2, key3: :value3 } }

    inputs  :args
    it_with [],                        Hash[]
    it_with %i[key1],                  Hash[key1: :value1]
    it_with %i[key2],                  Hash[key2: :value2]
    it_with %i[key3],                  Hash[key3: :value3]
    it_with %i[key1 key3],             Hash[key1: :value1, key3: :value3]
    it_with [%i[key1], nil, %i[key3]], Hash[key1: :value1, key3: :value3]
  end
end
