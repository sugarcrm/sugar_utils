# -*- encoding : utf-8 -*-

require 'sugar_utils/version'

module SugarUtils
  # @param [Object] value
  #
  # @return [Boolean]
  def self.ensure_boolean(value)
    return false if value.respond_to?(:to_s) && value.to_s.casecmp('false').zero?
    value ? true : false
  end

  # @param [String, Float, Integer] value
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
end
