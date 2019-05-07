Feature: Touch a file

Scenario: Touch a file
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils::File.touch('dir/test')
    """
  Then the file named "dir/test" should exist

# TODO: Fix the owner/group setting check
Scenario: Touch a file and reset its permissions and mtime
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    puts SugarUtils::File.touch(
      'dir/test',
      # owner: 'nobody',
      # group: 'nogroup',
      mode:  0o777,
      mtime: 0
    )
    """
  Then the file named "dir/test" should exist
    And the file named "dir/test" should have permissions "777"
    And the file named "dir/test" should have modification time "0"
    # And the file named "dir/test" should have owner "nobody"
    # And the file named "dir/test" should have group "nogroup"
