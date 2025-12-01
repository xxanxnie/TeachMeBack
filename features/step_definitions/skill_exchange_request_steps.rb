# features/step_definitions/skill_exchange_request_steps.rb

Given("I am logged in as a user with email {string} and password {string}") do |email, password|
  user = User.find_by(email: email)
  unless user
    user = User.create!(
      first_name: "Test",
      last_name: "User",
      name: "Test User",
      email: email,
      password: password,
      edu_verified: email.end_with?(".edu")
    )
  end
  
  visit login_path
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_button "Log In"
end

When("I select {string} from {string}") do |value, field|
  select value, from: field
end

When("I check availability day {string}") do |day|
  # Map day name to checkbox id
  day_map = {
    "Sun" => "day_0",
    "Mon" => "day_1",
    "Tue" => "day_2",
    "Wed" => "day_3",
    "Thu" => "day_4",
    "Fri" => "day_5",
    "Sat" => "day_6"
  }
  
  checkbox_id = day_map[day]
  if checkbox_id
    check checkbox_id
  else
    raise "Unknown day: #{day}. Valid days are: #{day_map.keys.join(', ')}"
  end
end

When("I uncheck availability day {string}") do |day|
  day_map = {
    "Sun" => "day_0",
    "Mon" => "day_1",
    "Tue" => "day_2",
    "Wed" => "day_3",
    "Thu" => "day_4",
    "Fri" => "day_5",
    "Sat" => "day_6"
  }
  
  checkbox_id = day_map[day]
  if checkbox_id
    uncheck checkbox_id
  else
    raise "Unknown day: #{day}. Valid days are: #{day_map.keys.join(', ')}"
  end
end

Then("I should be on the explore page") do
  unless page.current_path == "/explore"
    raise "Expected to be on /explore, but was on #{page.current_path}"
  end
end

# Helper for filling in textarea by label or id
When(/^I fill in the textarea "([^"]*)" with "([^"]*)"$/) do |field_label, value|
  # Try to find by label first
  label = page.find("label", text: /#{Regexp.escape(field_label)}/i)
  field_id = label[:for]
  if field_id
    fill_in field_id, with: value
  else
    # Fallback: try to fill by placeholder or nearby text
    page.fill_in field_label, with: value, match: :first
  end
rescue Capybara::ElementNotFound
  # Try alternative: find by name attribute
  field = page.find("textarea[name*='learning_goal']", match: :first)
  field.set(value)
end

# Helper step for checking if a skill exchange request exists
Then("a skill exchange request should exist with teach skill {string}") do |teach_skill|
  request = SkillExchangeRequest.find_by(teach_skill: teach_skill)
  unless request
    raise "Expected a skill exchange request with teach skill '#{teach_skill}' to exist, but it doesn't"
  end
end

Given("I have an open skill exchange request teaching {string} and learning {string}") do |teach, learn|
  user = User.first || raise("No users present to attach skill exchange request to")

  SkillExchangeRequest.find_or_create_by!(
    user: user,
    teach_skill: teach,
    learn_skill: learn
  ) do |req|
    req.teach_level = "intermediate"
    req.learn_level = "beginner"
    req.modality = "remote"
    req.offer_hours = 2
    req.expires_after_days = 30
    req.status = "open"
    req.availability_days = [1, 3]

    if SkillExchangeRequest.column_names.include?("teach_category")
      req.teach_category = "music_art"
    end
    if SkillExchangeRequest.column_names.include?("learn_category")
      req.learn_category = "tech_academics"
    end
  end
end

When("I visit my profile page") do
  visit "/profile"
end

Then("I should see {string} in my active skill exchange list") do |teach_skill|
  within(".card", text: "Active Skill Exchange Requests") do
    expect(page).to have_content(teach_skill)
  end
end

Then("I should see {string} in my history skill exchange list") do |teach_skill|
  within(".card", text: "History / Past Exchanges") do
    expect(page).to have_content(teach_skill)
  end
end

When("I click {string} on my {string} active request") do |button_text, teach_skill|
  within(".card", text: "Active Skill Exchange Requests") do
    row = page.find("li", text: teach_skill)
    within(row) do
      click_button(button_text)
    end
  end
end

# Helper step for viewing a skill exchange request
When("I view the skill exchange request with teach skill {string}") do |teach_skill|
  request = SkillExchangeRequest.find_by(teach_skill: teach_skill)
  if request
    visit skill_exchange_request_path(request)
  else
    raise "Skill exchange request with teach skill '#{teach_skill}' not found"
  end
end
