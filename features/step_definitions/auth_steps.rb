# features/step_definitions/auth_steps.rb
require "capybara/cucumber"

Given("I am on the home page") do
  visit "/"
end

When('I follow {string}') do |text|
  click_link text
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I press {string}') do |text|
  click_button text
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should be on the dashboard page') do
  # Dashboard is now at /explore
  unless page.current_path == "/explore"
    raise "Expected to be on /explore, but was on #{page.current_path}"
  end
end

# Temporary helper until we have full user auth in place
Given('a user exists with email {string} and password {string}') do |email, password|
  begin
    if defined?(User)
      user = User.find_by(email: email)
      user ||= User.create!(first_name: "Test", last_name: "User", name: "Test User", email: email, password: password, edu_verified: email.end_with?(".edu"))
    end
  rescue NameError
  end
end

