# frozen_string_literal: true

require 'sugar_utils/version'
require 'sugar_utils/file'

# @api
module SugarUtils
  # @param value [Object]
  #
  # @return [Boolean]
  def self.ensure_boolean(value)
    return false if value.respond_to?(:to_s) && value.to_s.casecmp('false').zero?

    value ? true : false
  end

  # @param value [String, Float, Integer]
  #
  # @raise [ArgumentError] if the value is a string which cannot be converted
  # @raise [TypeError] if value is type which cannot be converted
  #
  # @return [Integer]
  def self.ensure_integer(value)
    return value      if value.is_a?(Integer)
    return value.to_i if value.is_a?(Float)

    Float(value).to_i
  end

  # @overload scrub_encoding(data)
  #   Scrub the string's encoding, and replace any bad characters with ''.
  #   @param data [String]
  # @overload scrub_encoding(data, replacement_character)
  #   Scrub the string's encoding, and replace any bad characters with the
  #   specified character.
  #   @param data [String]
  #   @param replacement_character [String]
  #
  # @return [String]
  def self.scrub_encoding(data, replacement_character = nil)
    replacement_character = '' unless replacement_character.is_a?(String)

    # If the Ruby version being used supports String#scrub, then just use it.
    return data.scrub(replacement_character) if data.respond_to?(:scrub)

    # Otherwise, fall back to String#encode.
    data.encode(
      data.encoding,
      'binary',
      invalid: :replace,
      undef:   :replace, # rubocop:disable Layout/AlignHash
      replace: replacement_character
    )
  end
end
