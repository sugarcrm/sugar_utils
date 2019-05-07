Feature: Write to a file

Scenario: Write a file
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils::File.write('dir/test', 'foobar')
    """
  Then the file named "dir/test" should contain exactly:
    """
    foobar
    """

Scenario: Overwrite a file
  Given a file named "dir/test" with "deadbeef"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils::File.write('dir/test', 'foobar')
    """
  Then the file named "dir/test" should contain exactly:
    """
    foobar
    """

# TODO: Fix the owner/group setting check
Scenario: Overwrite a file and reset its permissions
  Given a file named "dir/test" with "deadbeef"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils::File.write(
      'dir/test',
      'foobar',
      # owner: 'nobody',
      # group: 'nogroup',
      mode:  0o777
    )
    """
  Then the file named "dir/test" should contain exactly:
    """
    foobar
    """
    And the file named "dir/test" should have permissions "777"
    # And the file named "dir/test" should have owner "nobody"
    # And the file named "dir/test" should have group "nogroup"
