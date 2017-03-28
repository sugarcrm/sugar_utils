# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Changed
- explicitly specify the Ruby v2.0.0 support limit

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
