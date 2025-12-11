def email_for(full_name)
  slug = full_name.to_s.strip.parameterize
  raise ArgumentError, "Full name required to derive email" if slug.blank?
  "#{slug}@columbia.edu"
end

DB_RETRY_ERRORS = [
  ActiveRecord::StatementTimeout
].tap do |errors|
  errors << ActiveRecord::LockWaitTimeout if defined?(ActiveRecord::LockWaitTimeout)
  errors << SQLite3::BusyException if defined?(SQLite3::BusyException)
end

def with_db_retry(attempts = 3)
  tries = 0
  begin
    yield
  rescue *DB_RETRY_ERRORS => e
    tries += 1
    raise e if tries >= attempts
    sleep(0.1 * tries)
    retry
  end
end

def ensure_user(identifier)
  email = identifier.to_s.include?("@") ? identifier : email_for(identifier)
  display_name =
    if identifier.to_s.include?("@")
      identifier.split("@").first.tr("._-", " ").squeeze(" ").strip.titleize
    else
      identifier
    end

  parts = display_name.to_s.split
  first = parts.first || display_name
  last  = parts.drop(1).join(" ").presence || "User"

  with_db_retry do
    User.find_or_create_by!(email: email) do |u|
      u.password = "password" if u.respond_to?(:password=)
      u.first_name = first if u.respond_to?(:first_name=)
      u.last_name  = last if u.respond_to?(:last_name=)
      u.name       = display_name if u.respond_to?(:name=)
      u.full_name  = display_name if u.respond_to?(:full_name=)
    end
  end
end

def normalize_modality(value)
  case value.to_s.strip.downcase
  when "remote", "online", "" then "remote"
  when "in person", "in-person", "in_person", "inperson", "onsite" then "in_person"
  when "hybrid" then "hybrid"
  else
    "remote"
  end
end

def parse_availability(value)
  return [0] if value.blank?

  tokens = value.is_a?(Array) ? value : value.to_s.split(/[, ]+/)
  tokens.map do |token|
    next if token.blank?
    if token =~ /\A\d+\z/
      token.to_i
    else
      SkillExchangeRequest::DAYS.find_index do |day|
        day.downcase.start_with?(token.to_s.downcase[0, 3])
      end
    end
  end.compact.presence || [0]
end

def create_skill_exchange_request(attrs = {})
  defaults = {
    user: ensure_user("default@columbia.edu"),
    teach_skill: "Guitar",
    teach_level: "intermediate",
    teach_category: "music_art",
    learn_skill: "Python",
    learn_level: "beginner",
    learn_category: "tech_academics",
    offer_hours: 2,
    modality: "remote",
    status: :open,
    expires_after_days: 30,
    availability_days: [1],
    created_at: Time.current
  }

  with_db_retry { SkillExchangeRequest.create!(defaults.merge(attrs)) }
end

def find_user!(full_name)
  ensure_user(full_name)
end

Given("the following users exist:") do |table|
  table.hashes.each do |row|
    identifier = row["email"].presence || row["user_email"].presence || row["full_name"].presence || row["name"]
    user = ensure_user(identifier)

    if row["email"].present? && user.email != row["email"]
      user.update!(email: row["email"])
    end

    if row["full_name"].present?
      parts = row["full_name"].split
      user.first_name = parts.first if user.respond_to?(:first_name=)
      user.last_name  = parts.drop(1).join(" ") if user.respond_to?(:last_name=)
      user.name       = row["full_name"] if user.respond_to?(:name=)
      user.full_name  = row["full_name"] if user.respond_to?(:full_name=)
      user.save! if user.changed?
    end

    if row["password"].present? && user.respond_to?(:password=)
      user.update!(password: row["password"])
    end
  end
end

Given("the following skill exchange requests exist:") do |table|
  table.hashes.each do |row|
    identifier = row["user_email"].presence || row["user_name"]
    user = ensure_user(identifier)

    create_skill_exchange_request(
      user: user,
      teach_skill: row["teach_skill"],
      teach_level: row["teach_level"] || "intermediate",
      teach_category: row["teach_category"] || "other",
      learn_skill: row["learn_skill"],
      learn_level: row["learn_level"] || "beginner",
      learn_category: row["learn_category"] || "other",
      offer_hours: (row["offer_hours"] || 1).to_i,
      modality: normalize_modality(row["modality"]),
      status: (row["status"] || "open"),
      created_at: row["created_days_ago"].present? ? row["created_days_ago"].to_i.days.ago : Time.current,
      expires_after_days: (row["expires_after_days"] || 30).to_i,
      availability_days: parse_availability(row["availability_days"])
    )
  end
end

When("I visit the home page as a guest") do
  visit("/")
end

When("I visit the explore page as a guest") do
  visit("/explore")
end

def login_as_full_name(full_name)
  user = find_user!(full_name)
  visit("/login")
  fill_in "Email", with: user.email
  fill_in "Password", with: "password"
  begin
    click_button("Log in", exact: false)
  rescue Capybara::ElementNotFound
    begin
      click_button("Login", exact: false)
    rescue Capybara::ElementNotFound
      begin
        click_button("Sign in", exact: false)
      rescue Capybara::ElementNotFound
        btn = first("button[type=submit], input[type=submit]")
        raise Capybara::ElementNotFound, "No submit button found on the login page" unless btn
        btn.click
      end
    end
  end
  user
end

When('I visit the explore page as {string}') do |full_name|
  login_as_full_name(full_name)
  visit("/explore")
end

When('I visit the explore page as {string} with query {string}') do |full_name, q|
  login_as_full_name(full_name)
  visit("/explore?q=#{CGI.escape(q)}")
end

Then("I should not see a link to the explore page") do
  expect(page).not_to have_link("Explore", href: "/explore")
end

Then("I should see a link to the explore page") do
  expect(page).to have_link("Explore", href: "/explore")
end

Then("I should be on the home page") do
  expect(URI.parse(current_url).path).to eq("/")
end

Then("I should see a request count of {int}") do |n|
  within("#request-count") do
    expect(page).to have_content(n.to_s)
  end
end

Then('I should see a "Create New Request" link to the new request page') do
  expect(page).to have_link("Create New Request", href: "/skill_exchange_requests/new")
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

Given('I am logged in as {string}') do |email|
  @current_user_email = email
  user = User.find_or_create_by!(email: email) do |u|
    u.password = "password" if u.respond_to?(:password=)
    if u.respond_to?(:name=)
      u.name = email.split('@').first.titleize
    end
    if u.respond_to?(:first_name=)
      u.first_name = email.split('@').first.titleize
    end
    if u.respond_to?(:last_name=)
      u.last_name = "User"
    end
    if u.respond_to?(:full_name=)
      u.full_name = u.respond_to?(:name) ? u.name : email
    end
  end

  visit("/login")
  fill_in "Email", with: user.email
  fill_in "Password", with: "password"
  begin
    click_button("Log in", exact: false)
  rescue Capybara::ElementNotFound
    btn = first("button[type=submit], input[type=submit]")
    raise Capybara::ElementNotFound, "No submit button found on the login page" unless btn
    btn.click
  end
end

When('I visit {string}') do |path|
  visit(path == "/dashboard" ? "/explore" : path)
end

When('I type {string} in the dashboard search box') do |term|
  current = URI.parse(current_url)
  base = current.path == "/dashboard" ? "/explore" : current.path
  visit("#{base}?q=#{CGI.escape(term)}")
end

Given("a closed skill exchange request exists") do
  user = ensure_user("closed@columbia.edu")
  create_skill_exchange_request(user: user, status: :closed, teach_skill: "Closed Skill", learn_skill: "Closed Learn")
end

Given("an expired skill exchange request exists") do
  user = ensure_user("expired@columbia.edu")
  create_skill_exchange_request(
    user: user,
    teach_skill: "Expired Skill",
    learn_skill: "Expired Learn",
    created_at: 200.days.ago,
    expires_after_days: 10
  )
end

When('a new open request is created by {string} with teach {string} and learn {string}') do |identifier, teach_skill, learn_skill|
  user = ensure_user(identifier)
  create_skill_exchange_request(
    user: user,
    teach_skill: teach_skill,
    learn_skill: learn_skill,
    created_at: Time.current,
    status: :open
  )

  current_path = URI.parse(current_url).path rescue nil
  visit(current_path) if current_path.present?
end
