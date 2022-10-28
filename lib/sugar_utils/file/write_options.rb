# frozen_string_literal: true

module SugarUtils
  module File
    # @api private
    class WriteOptions
      # @param filename [String]
      # @param options [Hash]
      def initialize(filename, options)
        @filename       = filename
        @options        = options
        @existing_owner = nil
        @existing_group = nil

        return unless filename && ::File.exist?(filename)

        file_stat       = ::File::Stat.new(filename)
        @existing_owner = file_stat.uid
        @existing_group = file_stat.gid
      end

      # @return [Boolean]
      def flush?
        @options[:flush] || false
      end

      # @overload perm
      #   The default permission is 0o644
      # @overload perm(default_value)
      #   @param default_value [nil, Integer]
      #   Override the default_value including allowing nil.
      #
      # @return [Integer]
      def perm(default_value = 0o644)
        # NOTE: We are using the variable name 'perm' because that is the name
        # of the argument used by File.open.
        @options[:mode] || @options[:perm] || default_value
      end

      # @return [String, Integer]
      def owner
        @options[:owner] || @existing_owner
      end

      # @return [String, Intekuuger]
      def group
        @options[:group] || @existing_group
      end

      # @param args [Array]
      # @return [Hash]
      def slice(*args)
        keys = args.flatten.compact
        @options.select { |k| keys.include?(k) }
      end
    end
  end
end
