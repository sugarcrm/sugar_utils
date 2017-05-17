# -*- encoding: utf-8 -*-

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require 'yardstick/rake/measurement'
require 'fileutils'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop) do |task|
  FileUtils.mkdir_p('tmp')
  task.options = %w[--format progress --format simple --out tmp/rubocop.txt]
end

YARD::Rake::YardocTask.new do |t|
  t.files         = ['lib/**/*.rb']
  t.stats_options = ['--list-undoc']
end

Yardstick::Rake::Measurement.new(:yardstick_measure) do |measurement|
  measurement.output = 'tmp/yard_coverage.txt'
end

task quality: %i[rubocop yardstick_measure]

task default: [:spec]
