Feature: Ensure the specified value is an integer

Scenario: Convert Floats to Integers
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.ensure_integer(123.456)
    """
  Then the output should contain "123"

Scenario: Convert Strings of Integers to Integers
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.ensure_integer('123.456')
    """
  Then the output should contain "123"


