Given /^I am on the homepage$/ do
  visit '/'
end

When /^I click "([^"]*)"/ do |text|
  click_on text
end

Then /^I should see "([^"]*)"/ do |text|
  page.html.should match text
end
