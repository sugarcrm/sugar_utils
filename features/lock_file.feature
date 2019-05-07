# TODO: Fill in this feature
Feature: Operate locks on files

Scenario: Shared lock
  Given a file named "test" with "foobar"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    File.open('test') do |file|
      SugarUtils::File.flock_shared(file)
      puts file.read
    end
    """
  Then the file named "test" should contain "foobar"

Scenario: Exclusive lock
  Given a file named "test" with "foobar"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    File.open('test') do |file|
      SugarUtils::File.flock_exclusive(file)
      puts file.read
    end
    """
  Then the file named "test" should contain "foobar"
