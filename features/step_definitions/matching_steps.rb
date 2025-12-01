# features/step_definitions/matching_steps.rb

def normalized_email_for(name)
  "#{name.to_s.strip.parameterize}@columbia.edu"
end

def find_user_by_email!(email)
  User.find_by!(email: email)
end

def find_user_by_name!(name)
  return find_user_by_email!(name) if name.to_s.include?("@")

  email = normalized_email_for(name)
  User.find_by(email: email) ||
    User.find_by(name: name) ||
    User.find_by(
      first_name: name.split.first,
      last_name: name.split.drop(1).join(" ")
    ) ||
    raise("User '#{name}' not found")
end

def find_card_for_owner!(owner_name)
  user = begin
    find_user_by_name!(owner_name)
  rescue StandardError
    nil
  end

  search_terms = [owner_name, user&.full_name].compact.map(&:to_s).map(&:strip).uniq

  candidates = page.all("[data-search-item]", minimum: 0)
  candidates = page.all(".card.shadow-sm", minimum: 0) if candidates.empty?

  card = candidates.find do |node|
    text = node.text.downcase
    search_terms.any? { |term| term.present? && text.include?(term.downcase) }
  end

  raise "Could not find skill request card for #{owner_name}" unless card
  card
end

Given("a user skill request exists from {string} to {string} for skill {string}") do |requester_name, receiver_name, skill|
  requester = find_user_by_name!(requester_name)
  receiver  = find_user_by_name!(receiver_name)

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
  card = find_card_for_owner!(owner_name)

  within(card) do
    begin
      click_button button_text
    rescue Capybara::ElementNotFound
      form = find("form[action*='user_skill_requests']", match: :first)
      form.find("input[type='submit'][value='#{button_text}']").click
    end
  end
end

When("I try to send a request to {string}") do |receiver_name|
  card = find_card_for_owner!(receiver_name)

  within(card) do
    form = find("form[action*='user_skill_requests']", match: :first)
    form.find("input[type='submit']").click
  end
end

Then("a user skill request should exist from {string} to {string} for skill {string}") do |requester_name, receiver_name, skill|
  requester = find_user_by_name!(requester_name)
  receiver  = find_user_by_name!(receiver_name)

  request = UserSkillRequest.find_by(
    requester: requester,
    receiver: receiver,
    skill: skill
  )

  expect(request).to be_present,
    "Expected a user skill request from #{requester_name} to #{receiver_name} for skill #{skill}, but it doesn't exist"
end

Then("a match should exist between {string} and {string}") do |user1_name, user2_name|
  user1 = find_user_by_name!(user1_name)
  user2 = find_user_by_name!(user2_name)

  user_ids = [user1.id, user2.id].sort

  match = Match.find_by(user1_id: user_ids[0], user2_id: user_ids[1])

  expect(match).to be_present,
    "Expected a match between #{user1_name} and #{user2_name}, but it doesn't exist"
  expect(match.status).to eq("mutual")
end

Then("a match should not exist between {string} and {string}") do |user1_name, user2_name|
  user1 = find_user_by_name!(user1_name)
  user2 = find_user_by_name!(user2_name)

  user_ids = [user1.id, user2.id].sort

  match = Match.find_by(user1_id: user_ids[0], user2_id: user_ids[1])
  expect(match).to be_nil,
    "Expected no match between #{user1_name} and #{user2_name}, but one exists"
end

Then("I should see {string} button on the skill request card for {string}") do |button_text, owner_name|
  card = find_card_for_owner!(owner_name)

  within(card) do
    expect(page).to have_button(button_text, disabled: :all, wait: 2)
  end
end

Then("I should not see {string} button on the skill request card for {string}") do |button_text, owner_name|
  card = find_card_for_owner!(owner_name)

  within(card) do
    expect(page).not_to have_button(button_text, disabled: :all)
  end
end

Then("I should not see {string} button on any skill request card") do |button_text|
  expect(page).not_to have_button(button_text, disabled: :all)
end

Then("only one user skill request should exist from {string} to {string}") do |requester_name, receiver_name|
  requester = find_user_by_name!(requester_name)
  receiver  = find_user_by_name!(receiver_name)

  count = UserSkillRequest.where(requester: requester, receiver: receiver).count
  expect(count).to eq(1),
    "Expected exactly 1 user skill request from #{requester_name} to #{receiver_name}, but found #{count}"
end

Then("I should see a match count of {int}") do |count|
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
  page.all(".card-body", minimum: 0).each do |card|
    expect(card).not_to have_content(text)
  end
end
