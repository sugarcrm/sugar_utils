Feature: Write JSON to a file

Scenario: Write a file
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    MultiJson.use(:ok_json)

    puts SugarUtils::File.write_json('dir/test.json', { key: :value })
    """
  Then the file named "dir/test.json" should contain exactly:
    """
    {"key":"value"}
    """

Scenario: Overwrite a file
  Given a file named "dir/test.json" with "deadbeef"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    MultiJson.use(:ok_json)

    puts SugarUtils::File.write_json('dir/test.json', { key: :value })
    """
  Then the file named "dir/test.json" should contain exactly:
    """
    {"key":"value"}
    """

# TODO: Fix the owner/group setting check
Scenario: Overwrite a file and reset its permissions
  Given a file named "dir/test.json" with "deadbeef"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    MultiJson.use(:ok_json)

    puts SugarUtils::File.write_json(
      'dir/test.json',
      { key: :value },
      # owner: 'nobody',
      # group: 'nogroup',
      mode:  0o777
    )
    """
  Then the file named "dir/test.json" should contain exactly:
    """
    {"key":"value"}
    """
    And the file named "dir/test.json" should have permissions "777"
    # And the file named "dir/test.json" should have owner "nobody"
    # And the file named "dir/test.json" should have group "nogroup"
