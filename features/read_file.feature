Feature: Read a file

Scenario: Read a missing file with a default value
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils::File.read(
      'test', value_on_missing: 'missing', raise_on_missing: false
    )
    """
  Then the output should contain "missing"

Scenario: Read an existing file
  Given a file named "test" with "foobar"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils::File.read('test')
    """
  Then the output should contain "foobar"

Scenario: Read an existing file and scurb encoding errors
  Given a file named "test" with "test"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    File.write('test', %(foo\\x92bar\\x93))
    puts SugarUtils::File.read('test', scrub_encoding: true)
    """
  Then the output should contain "foobar"
