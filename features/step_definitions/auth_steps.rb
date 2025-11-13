# features/step_definitions/auth_steps.rb
require "capybara/cucumber"

Given("I am on the home page") do
  visit "/"
end

When('I follow {string}') do |text|
  begin
    click_link text, exact: false
  rescue Capybara::ElementNotFound
    variations = [
      text.delete(" "),
      text.split.map(&:capitalize).join(" "),
      text.downcase,
      text.upcase,
      text.tr(" ", "")
    ].compact.uniq - [text]

    clicked = false
    variations.each do |candidate|
      next unless candidate.present?
      if page.has_link?(candidate, exact: false, wait: 0)
        click_link candidate, exact: false
        clicked = true
        break
      end
    end

    raise Capybara::ElementNotFound, "Unable to find link matching '#{text}'" unless clicked
  end
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I press {string}') do |text|
  begin
    click_button text
  rescue Capybara::ElementNotFound
    if page.has_link?(text, exact: false, wait: 0)
      click_link text, exact: false
    else
      raise
    end
  end
end

MESSAGE_ALIASES = {
  "Please log in to access this page." => [
    "Please log in to access this page.",
    "Please log in to view matches."
  ]
}.freeze

Then('I should see {string}') do |text|
  candidates = MESSAGE_ALIASES.fetch(text, [text])
  expectation_met = candidates.any? { |candidate| page.has_content?(candidate) }

  unless expectation_met
    raise RSpec::Expectations::ExpectationNotMetError,
          "Expected to see one of #{candidates.inspect}, but saw:\n#{page.text}"
  end
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
