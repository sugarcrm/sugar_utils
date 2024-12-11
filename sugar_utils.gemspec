# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sugar_utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'sugar_utils'
  spec.version       = SugarUtils::VERSION
  spec.authors       = ['Andrew Sullivan Cant']
  spec.email         = ['acant@sugarcrm.com']

  spec.summary       = 'Utility methods extracted from SugarCRM Ruby projects.'
  spec.homepage      = 'http://github.com/sugarcrm/sugar_utils'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1.2'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'multi_json',   '~> 1.0'
  spec.add_dependency 'solid_assert', '~> 1.0'

  spec.add_development_dependency 'aruba',              '~> 2.0'
  spec.add_development_dependency 'cucumber',           '~> 8.0'
  spec.add_development_dependency 'fakefs',             '~> 1.0'
  spec.add_development_dependency 'rake',               '~> 13.0'
  spec.add_development_dependency 'rspec',              '~> 3.8'
  spec.add_development_dependency 'rspec-side_effects', '~> 0.2.0'
  spec.add_development_dependency 'rspec-tabular',      '~> 0.3.0'

  # Dependencies whose APIs we do not really depend upon, and can be upgraded
  # without limiting.
  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'irb'
  spec.add_development_dependency 'license_finder'
  spec.add_development_dependency 'logger'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-lcov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'yardstick'
end
