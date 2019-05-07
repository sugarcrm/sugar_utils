When('I run the following Ruby code:') do |code|
  run_command_and_stop %(ruby -e "#{code}")
end

# Copying the pattern for this step from the default Aruba step for checking
# the permissions of a file.
# @see lib/aruba/cucumber/file.rb
Then(/^the (?:file|directory)(?: named)? "([^"]*)" should( not)? have owner "([^"]*)"$/) do |path, negated, owner|
  if negated
    expect(path).not_to have_owner(owner)
  else
    expect(path).to have_owner(owner)
  end
end

# Copying the pattern for this step from the default Aruba step for checking
# the permissions of a file.
# @see lib/aruba/cucumber/file.rb
Then(/^the (?:file|directory)(?: named)? "([^"]*)" should( not)? have group "([^"]*)"$/) do |path, negated, group|
  if negated
    expect(path).not_to have_group(group)
  else
    expect(path).to have_group(group)
  end
end

# Copying the pattern for this step from the default Aruba step for checking
# the permissions of a file.
# @see lib/aruba/cucumber/file.rb
Then(/^the (?:file|directory)(?: named)? "([^"]*)" should( not)? have modification time "([^"]*)"$/) do |path, negated, modification_time|
  if negated
    expect(expand_path(path)).not_to have_mtime(modification_time.to_i)
  else
    expect(expand_path(path)).to have_mtime(modification_time.to_i)
  end
end
