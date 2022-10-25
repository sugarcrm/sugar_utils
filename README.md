# sugar_utils

[![Gem Version](https://badge.fury.io/rb/sugar_utils.svg)](http://badge.fury.io/rb/sugar_utils)
[![Build Status](https://github.com/sugarcrm/sugar_utils/actions/workflows/ci.yml/badge.svg)](https://github.com/sugarcrm/sugar_utils/actions/workflows/ci.yml)
[![Code Climate](https://codeclimate.com/github/sugarcrm/sugar_utils/badges/gpa.svg)](https://codeclimate.com/github/sugarcrm/sugar_utils)
[![Test Coverage](https://codeclimate.com/github/sugarcrm/sugar_utils/badges/coverage.svg)](https://codeclimate.com/github/sugarcrm/sugar_utils/coverage)
[![License](http://img.shields.io/badge/license-Apache2-green.svg?style=flat)](LICENSE)

[![RubyDoc](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://rubydoc.org/gems/sugar_utils)
[![CucumberReports: sugar_utils](https://messages.cucumber.io/api/report-collections/7a992611-6430-4ca9-ae77-aa071ba60c8b/badge)](https://reports.cucumber.io/report-collections/7a992611-6430-4ca9-ae77-aa071ba60c8b)

Utility methods extracted from SugarCRM Ruby projects.

These methods are included:

* SugarUtils.ensure_boolean
* SugarUtils.ensure_integer
* SugarUtils.scrub_encoding
* SugarUtils::File.flock_shared
* SugarUtils::File.flock_exclusive
* SugarUtils::File.change_access
* SugarUtils::File.read
* SugarUtils::File.write
* SugarUtils::File.atomic_write
* SugarUtils::File.read_json
* SugarUtils::File.write_json
* SugarUtils::File.append

## Installation

Add this line to your application's Gemfile:


```ruby
gem 'sugar_utils'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install sugar_utils
```

## Roadmap

These methods might be added in the future:

* sizeof_dir
* find_files
* find_file!
* gzip
* gunzip
* tarball
* untarball
* tarball_list
* encrypt
* http_get_file
* timeout_retry

## Elsewhere on the web

Links to other places on the web where this projects exists:

* [Code Climate](https://codeclimate.com/github/sugarcrm/sugar_utils)
* [Cucumber Reporting](https://reports.cucumber.io/report-collections/7a992611-6430-4ca9-ae77-aa071ba60c8b)
* [Github](https://github.com/sugarcrm/sugar_utils)
* [Kandi](https://kandi.openweaver.com/ruby/sugarcrm/sugar_utils)
* [OpenHub](https://www.openhub.net/p/sugar_utils)
* [RubyDoc](http://rubydoc.org/gems/sugar_utils)
* [RubyGems](https://rubygems.org/gems/sugar_utils)
* [Ruby LibHunt](https://ruby.libhunt.com/sugar_utils-alternatives)
* [Ruby Toolbox](https://www.ruby-toolbox.com/projects/sugar_utils)

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for how you can contribute changes back into this project.

## Contributors

* [Andrew Sullivan Cant](https://github.com/acant)
* [Robert Lockstone](https://github.com/lockstone)
* [Vadim Kazakov](https://github.com/yads)

## Acknowledgements

Copyright 2019 [SugarCRM Inc.](http://sugarcrm.com), released under the Apache2 License.
