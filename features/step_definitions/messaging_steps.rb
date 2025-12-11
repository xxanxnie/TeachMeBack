# frozen_string_literal: true

# --- helpers ---------------------------------------------------------------

def user_has_col?(col)
  User.column_names.include?(col.to_s)
end

def set_user_name!(user, display_name)
  if user_has_col?(:name)
    user.name = display_name
    return
  end

  if user_has_col?(:full_name)
    user.full_name = display_name
    return
  end

  if user_has_col?(:first_name) || user_has_col?(:last_name)
    parts = display_name.to_s.strip.split(/\s+/, 2)
    user.first_name = parts.first if user_has_col?(:first_name)
    user.last_name  = (parts.second || "") if user_has_col?(:last_name)
    return
  end
end

def find_user_by_name!(display_name)
  if user_has_col?(:name)
    u = User.find_by(name: display_name)
    return u if u
  end

  if user_has_col?(:full_name)
    u = User.find_by(full_name: display_name)
    return u if u
  end

  if user_has_col?(:first_name) || user_has_col?(:last_name)
    first, last = display_name.to_s.strip.split(/\s+/, 2)
    scope = User.all
    scope = scope.where(first_name: first) if user_has_col?(:first_name) && first.present?
    scope = scope.where(last_name: last)   if user_has_col?(:last_name)  && last.present?
    u = scope.first
    return u if u
  end

  raise ActiveRecord::RecordNotFound, "User '#{display_name}' not found"
end

# --- step definitions ------------------------------------------------------

Given(/^a user exists named "([^"]+)" with email "([^"]+)" and password "([^"]+)"$/) do |name, email, password|
  User.find_or_create_by!(email: email) do |u|
    set_user_name!(u, name)
    u.password = password
    u.password_confirmation = password if u.respond_to?(:password_confirmation)
  end
end

Given(/^a skill exchange request exists for "([^"]+)" teaching "([^"]+)" and learning "([^"]+)"$/) do |owner_name, teach, learn|
  owner = find_user_by_name!(owner_name)

  # Categories aligned with your other features
  teach_cat = "tech_academics" # Python
  learn_cat = "music_art"      # Guitar

  attrs = {
    user: owner,
    teach_skill: teach,
    learn_skill: learn,
    teach_level: "beginner",
    learn_level: "beginner",
    modality: "remote",
    offer_hours: 2,
    expires_after_days: 30,
    availability_days: %w[Mon Wed Fri],
    status: "open"
  }

  attrs[:teach_category] = teach_cat if SkillExchangeRequest.column_names.include?("teach_category")
  attrs[:learn_category] = learn_cat if SkillExchangeRequest.column_names.include?("learn_category")

  SkillExchangeRequest.create!(attrs)
end

Given(/^I am signed in as "([^"]+)" with password "([^"]+)"$/) do |email, password|
  visit "/login"
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_button "Log In"
end

When(/^I click "([^"]+)" on the request card for "([^"]+)"$/) do |link_text, owner_name|
  card = find(:xpath, "//div[@data-search-item][.//*[contains(normalize-space(.), #{owner_name.inspect})]]")
  within(card) do
    begin
      click_link(link_text, exact: false)
    rescue Capybara::ElementNotFound
      # Fallback for links with extra icons/whitespace
      link = all("a", minimum: 1).find { |a| a.text.include?(link_text) }
      raise Capybara::ElementNotFound, "Could not find link '#{link_text}' on card for #{owner_name}" unless link
      link.click
    end
  end
end

When("I click {string} on the match card for {string}") do |button_text, other_name|
  # Match cards are rendered in match/index inside .card-body elements
  cards = page.all(".card .card-body", minimum: 1)
  card = cards.find { |node| node.text.include?(other_name) } ||
         (raise "Could not find match card for #{other_name}")

  within(card) do
    click_link(button_text)
  end
end

Then(/^I should be on the message thread with "([^"]+)"$/) do |partner_name|
  expect(page).to have_current_path(%r{/messages/thread})
  expect(page).to have_content("Conversation with #{partner_name}")
end

When(/^I go to the message thread with "([^"]+)"$/) do |partner_name|
  user = find_user_by_name!(partner_name)
  visit Rails.application.routes.url_helpers.message_thread_path(with: user.id)
end

Given(/^a message exists from "([^"]+)" to "([^"]+)" with body "([^"]+)"$/) do |from_name, to_name, body|
  from = find_user_by_name!(from_name)
  to   = find_user_by_name!(to_name)
  Message.create!(sender: from, recipient: to, body: body)
end
