Feature: Append to a file

Scenario: Append a missing file
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    SugarUtils::File.append('dir/test', 'foobar')
    """
  Then the file named "dir/test" should contain exactly:
    """
    foobar
    """

Scenario: Append an existing file
  Given a file named "dir/test" with "foobar"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    SugarUtils::File.append('dir/test', 'deadbeef')
    """
  Then the file named "dir/test" should contain exactly:
    """
    foobardeadbeef
    """

# TODO: Fix the owner/group setting check
Scenario: Append a file and reset its permissions
  Given a file named "dir/test" with "foobar"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    SugarUtils::File.append(
      'dir/test',
      'deadbeef',
      # owner: 'nobody',
      # group: 'nogroup',
      mode:  0o777
    )
    """
  Then the file named "dir/test" should contain exactly:
    """
    foobardeadbeef
    """
    And the file named "dir/test" should have permissions "777"
    # And the file named "dir/test" should have owner "nobody"
    # And the file named "dir/test" should have group "nogroup"
