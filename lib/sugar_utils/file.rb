# -*- encoding : utf-8 -*-

require 'solid_assert'
require 'fileutils'
require 'multi_json'

module SugarUtils
  module File
    class Error < StandardError; end

    # flock with a timeout to ensure that it does not flock forever.
    #
    # @see http://www.codegnome.com/blog/2013/05/26/locking-files-with-ruby/
    #
    # @param [File] file
    # @param [File::LOCK_EX, File::LOCK_SH] locking_constant
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    #
    # @return [void]
    def self.flock(file, locking_constant, options = {})
      timeout = options[:timeout] || 10
      Timeout.timeout(timeout) { file.flock(locking_constant) }
    end

    # @param [String] filename
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :raise_on_missing (true)
    #
    # @raise [SugarUtils::File::Error)
    #
    # @return [Object]
    def self.read_json(filename, options = {})
      assert(options.is_a?(Hash), 'options MUST be a Hash')

      options[:raise_on_missing] = true unless options.key?(:raise_on_missing)

      ::File.open(filename, ::File::RDONLY) do |file|
        flock(file, ::File::LOCK_SH, options)
        MultiJson.load(file.read)
      end
    rescue SystemCallError, IOError
      raise(Error, "Cannot read #{filename}") if options[:raise_on_missing]
      {}
    rescue MultiJson::ParseError
      raise(Error, "Cannot parse #{filename}")
    rescue Timeout::Error
      raise(Error, "Cannot read #{filename} because it is locked")
    end
  end
end
