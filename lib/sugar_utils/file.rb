# -*- encoding : utf-8 -*-

module SugarUtils
  module File
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
  end
end
