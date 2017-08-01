# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.4.2] - 2017-08-01
### Changed
- default file creation permissions from 666 to 644.

## [0.4.1] - 2017-05-17
### Added
- options :owner, :group, :mode to SugarUtils::File.write and .touch

### Changed
- marked the :perm option as deprecated by :mode

## [0.4.0] - 2017-05-17
### Added
- SugarUtils::File.touch, which will ensure the directory before touching the
  specified file

## [0.3.0] - 2017-03-29
### Added
- SugarUtils::File.read, with locking and error handling when reading a plain
  text file
- SugarUtils::File.write, with locking and error handling when writing a plain
  text file

### Changed
- explicitly specify the Ruby v2.0.0 support limit
- divide SugarUtils::File.flock into .flock_shared and .flock_exclusive

## [0.2.0] - 2016-07-21
### Added
- SugarUtils::File.flock, for file locking with a timeout
- SugarUtils::File.read_json, with locking and error handling
- SugarUtils::File.write_json, with locking and error handling
- this CHANGELOG.md, following the http://keepachangelog.com/ guidelines

## [0.1.0] - 2016-07-09
### Added
- SugarUtils.ensure_boolean
- SugarUtils.ensure_integer
