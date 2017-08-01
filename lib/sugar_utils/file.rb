# -*- encoding : utf-8 -*-

require 'solid_assert'
require 'fileutils'
require 'multi_json'
require 'timeout'

module SugarUtils
  module File
    class Error < StandardError; end

    # @param [File] file
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    #
    # @raise [Timeout::Error]
    #
    # @return [void]
    def self.flock_shared(file, options = {})
      timeout = options[:timeout] || 10
      Timeout.timeout(timeout) { file.flock(::File::LOCK_SH) }
    end

    # @param [File] file
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    #
    # @raise [Timeout::Error]
    #
    # @return [void]
    def self.flock_exclusive(file, options = {})
      timeout = options[:timeout] || 10
      Timeout.timeout(timeout) { file.flock(::File::LOCK_EX) }
    end

    # @param [String] filename
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :raise_on_missing (true)
    # @option options [String] :value_on_missing ('') which specifies the
    #   value to return if the file is missing and raise_on_missing is false
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [String]
    def self.read(filename, options = {})
      options[:value_on_missing] ||= ''
      options[:raise_on_missing] = true if options[:raise_on_missing].nil?

      ::File.open(filename, ::File::RDONLY) do |file|
        flock_shared(file, options)
        file.read
      end
    rescue SystemCallError, IOError
      raise(Error, "Cannot read #{filename}") if options[:raise_on_missing]
      options[:value_on_missing]
    rescue Timeout::Error
      raise(Error, "Cannot read #{filename} because it is locked")
    end

    # @param [String] filename
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :raise_on_missing (true)
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [Object]
    def self.read_json(filename, options = {})
      options[:value_on_missing] = {}
      MultiJson.load(read(filename, options))
    rescue MultiJson::ParseError
      raise(Error, "Cannot parse #{filename}")
    end

    # @param [String] filename
    # @param [Hash] options
    # @option options [String, Integer] :owner
    # @option options [String, Integer] :group
    # @option options [Integer] :mode
    # @option options [Integer] :perm @deprecated
    #
    # @return [void]
    def self.touch(filename, options = {})
      owner = options[:owner]
      group = options[:group]
      mode  = options[:mode] || options[:perm]

      deprecate_option(:touch, :perm, :mode, 2017, 8) if options.has_key?(:perm)

      FileUtils.mkdir_p(::File.dirname(filename))
      FileUtils.touch(filename)
      FileUtils.chown(owner, group, filename)
      FileUtils.chmod(mode, filename) if mode
    end

    # @param [String] filename
    # @param [#to_s] data
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :flush (false)
    # @option options [String, Integer] :owner
    # @option options [String, Integer] :group
    # @option options [Integer] :mode (0o644)
    # @option options [Integer] :perm (0o644) @deprecated
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [void]
    def self.write(filename, data, options = {})
      flush = options[:flush] || false
      owner = options[:owner]
      group = options[:group]
      mode  = options[:mode] || options[:perm] || 0o644

      deprecate_option(:touch, :perm, :mode, 2017, 8) if options.has_key?(:perm)

      FileUtils.mkdir_p(::File.dirname(filename))
      ::File.open(filename, ::File::RDWR | ::File::CREAT, mode) do |file|
        flock_exclusive(file, options)

        file.truncate(0) # Ensure file is empty before proceeding.
        file.puts(data.to_s)

        # Flush and fsync to be 100% sure we write this data out now because we
        # are often reading it immediately and if the OS is buffering, it is
        # possible we might read it before it is been physically written to
        # disk. We are not worried about speed here, so this should be OKAY.
        if flush
          file.flush
          file.fsync
        end

        # Ensure that the permissions are correct if the file already existed.
        file.chmod(mode)
      end
      FileUtils.chown(owner, group, filename)
    rescue Timeout::Error
      raise(Error, "Unable to write #{filename} because it is locked")
    rescue SystemCallError, IOError => boom
      raise(Error, "Unable to write #{filename} with #{boom}")
    end

    # @param [String] filename
    # @param [#to_json] data
    # @param [Hash] options
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :flush (false)
    # @option options [Integer] :perm (0644)
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [void]
    def self.write_json(filename, data, options = {})
      write(filename, MultiJson.dump(data, pretty: true), options)
    end

    ############################################################################

    # Following the same pattern as the existing stdlib method deprecation
    # module.
    # @see http://ruby-doc.org/stdlib-2.0.0/libdoc/rubygems/rdoc/Gem/Deprecate.html
    def self.deprecate_option(_method, option_name, option_repl, year, month)
      return if Gem::Deprecate.skip

      klass  = self.is_a?(Module)
      target = klass ? "#{self}." : "#{self.class}#"

      # Determine the method
      method = caller_locations(1,1).first.label

      # Determine the caller
      external_caller             = caller_locations(2,1).first
      location_of_external_caller = "#{external_caller.absolute_path}:#{external_caller.lineno}"

      msg = [
        "NOTE: #{target}#{method} option :#{option_name} is deprecated",
        option_repl == :none ? ' with no replacement' : "; use :#{option_repl} instead",
        ". It will be removed on or after %4d-%02d-01." % [year, month],
        "\n#{target}#{method} called from #{location_of_external_caller}"
      ]
      warn("#{msg.join}.")
    end
    private_class_method :deprecate_option
  end
end
