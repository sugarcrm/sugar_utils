# frozen_string_literal: true

require 'solid_assert'
require 'fileutils'
require 'multi_json'
require 'timeout'

module SugarUtils
  module File
    class Error < StandardError; end

    # @param file [File]
    # @param options [Hash]
    # @option options [Integer] :timeout (10)
    #
    # @raise [Timeout::Error]
    #
    # @return [void]
    def self.flock_shared(file, options = {})
      timeout = options[:timeout] || 10
      Timeout.timeout(timeout) { file.flock(::File::LOCK_SH) }
    end

    # @param file [File]
    # @param options [Hash]
    # @option options [Integer] :timeout (10)
    #
    # @raise [Timeout::Error]
    #
    # @return [void]
    def self.flock_exclusive(file, options = {})
      timeout = options[:timeout] || 10
      Timeout.timeout(timeout) { file.flock(::File::LOCK_EX) }
    end

    # @param filename [String]
    # @param options [Hash]
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :raise_on_missing (true)
    # @option options [String] :value_on_missing ('') which specifies the
    #   value to return if the file is missing and raise_on_missing is false
    # @option options [Boolean, String] :scrub_encoding scrub incorrectly
    #   encoded characters with this value, or with '' if the value is true
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [String]
    def self.read(filename, options = {}) # rubocop:disable MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
      options[:value_on_missing] ||= ''
      options[:raise_on_missing] = true if options[:raise_on_missing].nil?

      result =
        ::File.open(filename, ::File::RDONLY) do |file|
          flock_shared(file, options)
          file.read
        end

      return result unless options[:scrub_encoding]

      replacement_character =
        if options[:scrub_encoding].is_a?(String)
          options[:scrub_encoding]
        else
          ''
        end
      if result.respond_to?(:scrub)
        result.scrub(replacement_character)
      else
        result.encode(
          result.encoding,
          'binary',
          invalid: :replace,
          undef:   :replace, # rubocop:disable Layout/AlignHash
          replace: replacement_character
        )
      end
    rescue SystemCallError, IOError
      raise(Error, "Cannot read #{filename}") if options[:raise_on_missing]

      options[:value_on_missing]
    rescue Timeout::Error
      raise(Error, "Cannot read #{filename} because it is locked")
    end

    # @param filename [String]
    # @param options [Hash]
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :raise_on_missing (true)
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [Object]
    def self.read_json(filename, options = {})
      options[:value_on_missing] = :missing

      read_result = read(filename, options)
      return {} if read_result == :missing

      MultiJson.load(read_result)
    rescue MultiJson::ParseError
      raise(Error, "Cannot parse #{filename}")
    end

    # Touch the specified file.
    #
    # @param filename [String]
    # @param options [Hash]
    # @option options [String, Integer] :owner
    # @option options [String, Integer] :group
    # @option options [Integer] :mode
    # @option options [Integer] :perm
    # @option options [Integer] :mtime
    #
    # @return [void]
    def self.touch(filename, options = {})
      owner         = options[:owner]
      group         = options[:group]
      perm          = options[:mode] || options[:perm]
      touch_options = options.select { |k| %i[mtime].include?(k) }

      FileUtils.mkdir_p(::File.dirname(filename))
      FileUtils.touch(filename, touch_options)
      FileUtils.chown(owner, group, filename)
      FileUtils.chmod(perm, filename) if perm
    end

    # Write to an existing file, overwriting it, or create the file if it does
    # not exist.
    #
    # @note Either option :mode or :perm can be used to specific the permissions
    # on the file being written to. This aliasing is used because both these
    # names are used in the standard library, File.open uses :perm and FileUtils
    # uses :mode. The user can choose whichever alias makes their code most
    # readable.
    #
    # @param filename [String]
    # @param data [#to_s]
    # @param options [Hash]
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :flush (false)
    # @option options [String, Integer] :owner
    # @option options [String, Integer] :group
    # @option options [Integer] :mode (0o644)
    # @option options [Integer] :perm (0o644)
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [void]
    def self.write(filename, data, options = {}) # rubocop:disable MethodLength, AbcSize, CyclomaticComplexity
      flush = options[:flush] || false
      owner = options[:owner]
      group = options[:group]
      # NOTE: We are using the variable name 'perm' because that is the name of
      # the argument used by File.open.
      perm  = options[:mode] || options[:perm] || 0o644

      # If the file exists and ownership or permissions are not specified, then
      # preserve those values from the original file.
      if ::File.exist?(filename)
        file_stat = ::File::Stat.new(filename)
        owner ||= file_stat.uid
        group ||= file_stat.gid
        perm  ||= file.mode
      end

      FileUtils.mkdir_p(::File.dirname(filename))
      ::File.open(filename, 'w+', perm) do |file|
        flock_exclusive(file, options)

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
        file.chmod(perm)
      end
      FileUtils.chown(owner, group, filename)
    rescue Timeout::Error
      raise(Error, "Unable to write #{filename} because it is locked")
    rescue SystemCallError, IOError => boom
      raise(Error, "Unable to write #{filename} with #{boom}")
    end

    # Write the data parameter as JSON to the filename path.
    #
    # @note Either option :mode or :perm can be used to specific the permissions
    # on the file being written to. This aliasing is used because both these
    # names are used in the standard library, File.open uses :perm and FileUtils
    # uses :mode. The user can choose whichever alias makes their code most
    # readable.
    #
    # @param filename [String]
    # @param data [#to_json]
    # @param options [Hash]
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :flush (false)
    # @option options [String, Integer] :owner
    # @option options [String, Integer] :group
    # @option options [Integer] :mode (0o644)
    # @option options [Integer] :perm (0o644)
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [void]
    def self.write_json(filename, data, options = {})
      write(filename, MultiJson.dump(data, pretty: true), options)
    end

    # Append to an existing file, or create the file if it does not exist.
    #
    # @note Either option :mode or :perm can be used to specific the permissions
    # on the file being written to. This aliasing is used because both these
    # names are used in the standard library, File.open uses :perm and FileUtils
    # uses :mode. The user can choose whichever alias makes their code most
    # readable.
    #
    # @param filename [String]
    # @param data [#to_s]
    # @param options [Hash]
    # @option options [Integer] :timeout (10)
    # @option options [Boolean] :flush (false)
    # @option options [String, Integer] :owner
    # @option options [String, Integer] :group
    # @option options [Integer] :mode (0o644)
    # @option options [Integer] :perm (0o644)
    #
    # @raise [SugarUtils::File::Error]
    #
    # @return [void]
    def self.append(filename, data, options = {}) # rubocop:disable MethodLength, AbcSize, CyclomaticComplexity
      flush = options[:flush] || false
      owner = options[:owner]
      group = options[:group]
      # NOTE: We are using the variable name 'perm' because that is the name of
      # the argument used by File.open.
      perm  = options[:mode] || options[:perm] || 0o644

      # If the file exists and ownership or permissions are not specified, then
      # preserve those values from the original file.
      if ::File.exist?(filename)
        file_stat = ::File::Stat.new(filename)
        owner ||= file_stat.uid
        group ||= file_stat.gid
        perm  ||= file.mode
      end

      FileUtils.mkdir_p(::File.dirname(filename))
      ::File.open(filename, 'a', perm) do |file|
        flock_exclusive(file, options)

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
        file.chmod(perm)
      end
      FileUtils.chown(owner, group, filename)
    rescue Timeout::Error
      raise(Error, "Unable to write #{filename} because it is locked")
    rescue SystemCallError, IOError => boom
      raise(Error, "Unable to write #{filename} with #{boom}")
    end

    ############################################################################

    # Following the same pattern as the existing stdlib method deprecation
    # module.
    # @see http://ruby-doc.org/stdlib-2.0.0/libdoc/rubygems/rdoc/Gem/Deprecate.html
    def self.deprecate_option(_method, option_name, option_repl, year, month) # rubocop:disable MethodLength
      return if Gem::Deprecate.skip

      klass  = is_a?(Module)
      target = klass ? "#{self}." : "#{self.class}#"

      # Determine the method
      method = caller_locations(1, 1).first.label

      # Determine the caller
      external_caller             = caller_locations(2, 1).first
      location_of_external_caller = "#{external_caller.absolute_path}:#{external_caller.lineno}"

      msg = [
        "NOTE: #{target}#{method} option :#{option_name} is deprecated",
        case option_repl
        when :none
          ' with no replacement'
        when String
          option_repl
        else
          "; use :#{option_repl} instead"
        end,
        format('. It will be removed on or after %4d-%02d-01.', year, month),
        "\n#{target}#{method} called from #{location_of_external_caller}"
      ]
      warn("#{msg.join}.")
    end
    private_class_method :deprecate_option
  end
end
