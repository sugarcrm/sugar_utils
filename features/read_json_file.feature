Feature: Read a file

Scenario: Read a missing file with a default value
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    MultiJson.use(:ok_json)

    puts SugarUtils::File.read_json('test.json', raise_on_missing: false)
    """
  Then the output should contain "{}"

Scenario: Read an existing file
  Given a file named "test.json" with:
    """
    {"key":"value"}
    """
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    MultiJson.use(:ok_json)

    puts SugarUtils::File.read_json('test.json')
    """
  Then the output should match:
    """
    {"key"\s*=>\s*"value"}
    """

Scenario: Read an existing file and scurb encoding errors
  Given a file named "test.json" with "test"
  When I run the following Ruby code:
    """ruby
    require 'sugar_utils'
    MultiJson.use(:ok_json)

    File.write('test.json', %({\"key\":\"foo\\x92bar\\x93\"}))
    puts SugarUtils::File.read_json('test.json', scrub_encoding: true)
    """
  Then the output should match:
    """
    {"key"\s*=>\s*"foobar"}
    """
