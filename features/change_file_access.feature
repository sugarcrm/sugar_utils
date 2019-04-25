Feature: Change a files ownership and permissions

# TODO: Fix the owner/group setting check. I need to figure out how to execute
# these scenarios correctly across various environments.

Scenario: All the values are skipped
  Given a file named "test" with "foobar"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    SugarUtils::File.change_access('test', nil, nil, nil)
    """
  # Then the file named "test" should have permissions "644"
    # And the file named "test" should have owner "nobody"
    # And the file named "test" should have group "nogroup"

Scenario: All the values are set
  Given a file named "test" with "foobar"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    # SugarUtils::File.change_access('test', 'nobody', 'nogroup', 0o777)
    SugarUtils::File.change_access('test', nil, nil, 0o777)
    """
  Then the file named "test" should have permissions "777"
    # And the file named "test" should have owner "nobody"
    # And the file named "test" should have group "nogroup"
