# -*- encoding: utf-8 -*-
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'fileutils'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop) do |task|
  FileUtils.mkdir_p('tmp')
  task.options = %w(--format progress --format simple --out tmp/rubocop.txt)
end

task default: :spec
