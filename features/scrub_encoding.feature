Feature: Ensure the specified value is an integer

Scenario: Pass through string without encoding errors
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.scrub_encoding('foobar')
    """
  Then the output should contain "foobar"

Scenario: Erase encoding errors in the string
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.scrub_encoding(%(foo\\x92bar\\x93))
    """
  Then the output should contain "foobar"

Scenario: Replace encoding errors in the string
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.scrub_encoding(%(foo\\x92bar\\x93), 'xxx')
    """
  Then the output should contain "fooxxxbarxxx"
