
Feature: Ensure the specified value is a boolean

Scenario: nil is false
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.ensure_boolean(nil)
    """
  Then the output should contain "false"

Scenario: false is false
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.ensure_boolean(false)
    """
  Then the output should contain "false"

Scenario: String of 'false' is false
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.ensure_boolean('false')
    """
  Then the output should contain "false"

Scenario: Any other value is true
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils.ensure_boolean('value')
    """
  Then the output should contain "true"
