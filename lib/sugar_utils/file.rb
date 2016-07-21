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

      options[:raise_on_missing] = true if options[:raise_on_missing].nil?

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

    # @param [String] filename
    # @param [#to_json]  data
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :flush (false)
    # @option options [Integer] :perm (0666)
    #
    # @raise [SugarUtils::File::Error)
    #
    # @return [void]
    def self.write_json(filename, data, options = {})
      perm  = options[:perm] || 0666
      flush = options[:flush] || false

      FileUtils.mkdir_p(::File.dirname(filename))
      ::File.open(filename, ::File::RDWR | ::File::CREAT, perm) do |file|
        flock(file, ::File::LOCK_EX, options)

        file.truncate(0) # Ensure file is empty before proceeding.
        file.puts(MultiJson.dump(data, pretty: true))

        # Flush and fsync to be 100% sure we write this data out now because we
        # are often reading it immediately and if the OS is buffering, it is
        # possible we might read it before it is been physically written to disk.
        # We are not worried about speed here, so this should be OKAY.
        if flush
          file.flush
          file.fsync
        end

        # Ensure that the permissions are correct if the file already existed.
        file.chmod(perm)
      end
    rescue Timeout::Error
      raise(Error, "Unable to write #{filename} because it is locked")
    rescue SystemCallError, IOError => boom
      raise(Error, "Unable to write #{filename} with #{boom}")
    end
  end
end
