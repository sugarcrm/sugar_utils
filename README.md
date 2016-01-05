# sugar-utils

[![Gem Version](https://badge.fury.io/rb/sugar-utils.svg)](http://badge.fury.io/rb/sugar-utils)
[![Dependency Status](https://gemnasium.com/sugarcrm/sugar-utils.svg)](https://gemnasium.com/sugarcrm/sugar-utils)
[![Build Status](https://travis-ci.org/sugarcrm/sugar-utils.svg?branch=master)](https://travis-ci.org/sugarcrm/sugar-utils)
[![Coverage Status](http://img.shields.io/coveralls/sugarcrm/sugar-utils/master.svg)](https://coveralls.io/r/sugarcrm/sugar-utils)
[![Code Climate](https://codeclimate.com/github/sugarcrm/sugar-utils/badges/gpa.svg)](https://codeclimate.com/github/sugarcrm/sugar-utils)
[![Inline docs](http://inch-ci.org/github/sugarcrm/sugar-utils.svg)](http://inch-ci.org/github/sugarcrm/sugar-utils)
[![License](http://img.shields.io/badge/license-Apache2-green.svg?style=flat)](LICENSE)

Utility methods extracted from SugarCRM Ruby projects.

These are the methods which are being extracted:

* sizeof_dir
* find_files
* find_file!
* read_json
* write_json
* gzip
* gunzip
* tarball
* untarball
* tarball_list
* encrypt
* http_get_file
* timeout_retry
* ensure_boolean
* ensure_time
* ensure_date_time
* ensure_integer!
* flock_with_timeout

## Installation

Add this line to your application's Gemfile:


```ruby
gem 'sugar-utils'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install sugar-utils
```

## Contributing

1. Fork it ( https://github.com/sugarcrm/sugar-utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Acknowledgments

Copyright 2016 [SugarCRM Inc.](http://sugarcrm.com), released under the Apache2 License.
