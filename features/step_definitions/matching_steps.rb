# features/step_definitions/matching_steps.rb

def find_user_by_email!(email)
  User.find_by!(email: email)
end

def find_user_by_name!(name)
  email = "#{name.to_s.parameterize}@columbia.edu"
  User.find_by!(email: email) || 
    User.find_by(name: name) ||
    User.find_by(first_name: name.split.first, last_name: name.split.drop(1).join(" ")) ||
    raise("User '#{name}' not found")
end

Given("a user skill request exists from {string} to {string} for skill {string}") do |requester_name, receiver_name, skill|
  requester = find_user_by_name!(requester_name)
  receiver = find_user_by_name!(receiver_name)
  
  UserSkillRequest.find_or_create_by!(
    requester: requester,
    receiver: receiver,
    skill: skill
  )
end

Given("a match exists between {string} and {string}") do |user1_name, user2_name|
  user1 = find_user_by_name!(user1_name)
  user2 = find_user_by_name!(user2_name)
  
  user_ids = [user1.id, user2.id].sort
  
  Match.find_or_create_by!(
    user1_id: user_ids[0],
    user2_id: user_ids[1],
    status: "mutual"
  )
end

When("I click {string} on the skill request card for {string}") do |button_text, owner_name|
  # First, find the user to get their actual displayed name
  user = find_user_by_name!(owner_name)
  displayed_name = user.full_name
  
  # Find the card by looking for the owner's displayed name
  # Try multiple strategies to find the card
  card = nil
  
  begin
    # Strategy 1: Find by data-search-item and containing text (try both names)
    card = page.find(:xpath, "//div[@data-search-item][.//*[contains(text(), '#{displayed_name}')]]", match: :first)
  rescue Capybara::ElementNotFound
    begin
      # Try with the original name too
      card = page.find(:xpath, "//div[@data-search-item][.//*[contains(text(), '#{owner_name}')]]", match: :first)
    rescue Capybara::ElementNotFound
      # Strategy 2: Find by class and text content
      all_cards = page.all(".card.shadow-sm")
      card = all_cards.find { |c| c.text.include?(displayed_name) || c.text.include?(owner_name) }
    end
  end
  
  raise "Could not find skill request card for #{owner_name} (displayed as: #{displayed_name})" unless card
  
  within(card) do
    # Try to find the button by text
    begin
      click_button button_text
    rescue Capybara::ElementNotFound
      # Try finding by form submission
      form = find("form[action*='user_skill_requests']", match: :first)
      form.find("input[type='submit'][value='#{button_text}']").click
    end
  end
end

When("I try to send a request to {string}") do |receiver_name|
  # This simulates trying to send a duplicate request
  # First, find the user to get their actual displayed name
  user = find_user_by_name!(receiver_name)
  displayed_name = user.full_name
  
  # Find a skill request card for this user and try to submit the form
  card = nil
  
  begin
    card = page.find(:xpath, "//div[@data-search-item][.//*[contains(text(), '#{displayed_name}')]]", match: :first)
  rescue Capybara::ElementNotFound
    begin
      card = page.find(:xpath, "//div[@data-search-item][.//*[contains(text(), '#{receiver_name}')]]", match: :first)
    rescue Capybara::ElementNotFound
      all_cards = page.all(".card.shadow-sm")
      card = all_cards.find { |c| c.text.include?(displayed_name) || c.text.include?(receiver_name) }
    end
  end
  
  raise "Could not find skill request card for #{receiver_name} (displayed as: #{displayed_name})" unless card
  
  within(card) do
    form = find("form[action*='user_skill_requests']", match: :first)
    form.find("input[type='submit']").click
  end
end

Then("a user skill request should exist from {string} to {string} for skill {string}") do |requester_name, receiver_name, skill|
  requester = find_user_by_name!(requester_name)
  receiver = find_user_by_name!(receiver_name)
  
  request = UserSkillRequest.find_by(
    requester: requester,
    receiver: receiver,
    skill: skill
  )
  
  expect(request).to be_present, "Expected a user skill request from #{requester_name} to #{receiver_name} for skill #{skill}, but it doesn't exist"
end

Then("a match should exist between {string} and {string}") do |user1_name, user2_name|
  user1 = find_user_by_name!(user1_name)
  user2 = find_user_by_name!(user2_name)
  
  user_ids = [user1.id, user2.id].sort
  
  match = Match.find_by(
    user1_id: user_ids[0],
    user2_id: user_ids[1]
  )
  
  expect(match).to be_present, "Expected a match between #{user1_name} and #{user2_name}, but it doesn't exist"
  expect(match.status).to eq("mutual")
end

Then("I should see {string} button on the skill request card for {string}") do |button_text, owner_name|
  # First, find the user to get their actual displayed name
  user = find_user_by_name!(owner_name)
  displayed_name = user.full_name
  
  # Try multiple strategies to find the card
  card = nil
  
  begin
    card = page.find(:xpath, "//div[@data-search-item][.//*[contains(text(), '#{displayed_name}')]]", match: :first)
  rescue Capybara::ElementNotFound
    begin
      card = page.find(:xpath, "//div[@data-search-item][.//*[contains(text(), '#{owner_name}')]]", match: :first)
    rescue Capybara::ElementNotFound
      all_cards = page.all(".card.shadow-sm")
      card = all_cards.find { |c| c.text.include?(displayed_name) || c.text.include?(owner_name) }
    end
  end
  
  raise "Could not find skill request card for #{owner_name} (displayed as: #{displayed_name})" unless card
  
  within(card) do
    # Check for button (can be enabled or disabled)
    expect(page).to have_button(button_text, wait: 2)
  end
end

Then("I should not see {string} button on the skill request card for {string}") do |button_text, owner_name|
  # First, find the user to get their actual displayed name
  user = find_user_by_name!(owner_name)
  displayed_name = user.full_name
  
  # Try multiple strategies to find the card
  card = nil
  
  begin
    card = page.find(:xpath, "//div[@data-search-item][.//*[contains(text(), '#{displayed_name}')]]", match: :first)
  rescue Capybara::ElementNotFound
    begin
      card = page.find(:xpath, "//div[@data-search-item][.//*[contains(text(), '#{owner_name}')]]", match: :first)
    rescue Capybara::ElementNotFound
      all_cards = page.all(".card.shadow-sm")
      card = all_cards.find { |c| c.text.include?(displayed_name) || c.text.include?(owner_name) }
    end
  end
  
  raise "Could not find skill request card for #{owner_name} (displayed as: #{displayed_name})" unless card
  
  within(card) do
    expect(page).not_to have_button(button_text)
  end
end

Then("I should not see {string} button on any skill request card") do |button_text|
  expect(page).not_to have_button(button_text)
end

Then("only one user skill request should exist from {string} to {string}") do |requester_name, receiver_name|
  requester = find_user_by_name!(requester_name)
  receiver = find_user_by_name!(receiver_name)
  
  count = UserSkillRequest.where(
    requester: requester,
    receiver: receiver
  ).count
  
  expect(count).to eq(1), "Expected exactly 1 user skill request from #{requester_name} to #{receiver_name}, but found #{count}"
end

Then("I should see a match count of {int}") do |count|
  # Look for the badge with the count - it might be in different locations
  expect(page).to have_css(".badge.bg-primary", text: count.to_s, wait: 2)
end

Then("I should see a link to {string}") do |link_text|
  expect(page).to have_link(link_text)
end

When("I log out") do
  if page.has_link?("Logout")
    click_link "Logout"
  elsif page.has_button?("Logout")
    click_button "Logout"
  end
end

Then("I should not see {string} in the match cards") do |text|
  # Check that the text doesn't appear in match cards specifically
  # (it might appear elsewhere on the page, like in navigation)
  within(".card-body") do
    expect(page).not_to have_content(text)
  end
end

