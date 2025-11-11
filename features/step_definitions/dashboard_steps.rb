def email_for(full_name)
  "#{full_name.to_s.parameterize}@columbia.edu"
end

def find_user!(full_name)
  email = email_for(full_name)
  User.find_by(email: email) ||
    User.find_by(name: full_name) ||
    User.find_by(full_name: full_name) rescue nil ||
    User.find_by(first_name: full_name.split.first, last_name: full_name.split.drop(1).join(" ")) ||
    raise("User '#{full_name}' not found. Did you create it in Background?")
end

Given("the following users exist:") do |table|
  table.hashes.each do |row|
    full_name = row["full_name"]
    email = email_for(full_name)
    User.find_or_create_by!(email: email) do |u|
      u.password = "password" if u.respond_to?(:password=)
      if u.respond_to?(:name=)
        u.name = full_name
      end
      if u.respond_to?(:first_name=) || u.respond_to?(:last_name=)
        parts = full_name.split
        u.first_name = parts.first if u.respond_to?(:first_name=)
        u.last_name  = parts.drop(1).join(" ") if u.respond_to?(:last_name=)
      end
      if u.respond_to?(:full_name=)
        u.full_name = full_name
      end
    end
  end
end

Given("the following skill exchange requests exist:") do |table|
  normalize_modality = lambda do |m|
    return nil if m.nil?
    mm = m.to_s.strip.downcase
    return "remote" if %w[remote online].include?(mm)
    return "in person" if %w[in person in-person in_person inperson onsite].include?(mm)
    mm
  end

  day_lookup = {}
  if defined?(SkillExchangeRequest::DAYS)
    SkillExchangeRequest::DAYS.each_with_index do |label, idx|
      day_lookup[label.to_s.downcase] = idx
    end
  end

  parse_availability_days = lambda do |value|
    return [0] if value.nil? || value.to_s.strip == ""

    raw_values =
      case value
      when Array then value
      else value.to_s.split(/[, ]+/)
      end

    raw_values.map do |token|
      next if token.to_s.strip == ""
      normalized = token.to_s.strip.downcase
      if normalized.match?(/\A\d+\z/)
        normalized.to_i
      else
        key = normalized[0, 3]
        day_lookup[key] || day_lookup[normalized]
      end
    end.compact.presence || [0]
  end

  table.hashes.each do |row|
    user =
      if row["user_email"].to_s.strip != ""
        User.find_or_create_by!(email: row["user_email"]) do |u|
          u.password = "password" if u.respond_to?(:password=)
          if u.respond_to?(:name=)
            u.name = row["user_email"].split("@").first.titleize
          end
          if u.respond_to?(:first_name=)
            u.first_name = row["user_email"].split("@").first.titleize
          end
          if u.respond_to?(:last_name=)
            u.last_name = "User"
          end
          if u.respond_to?(:full_name=)
            u.full_name = u.respond_to?(:name) ? u.name : row["user_email"]
          end
        end
      else
        find_user!(row["user_name"])
      end

    created_days_ago = row["created_days_ago"].to_i
    attrs = {
      teach_skill:        row["teach_skill"],
      learn_skill:        row["learn_skill"],
      teach_level:        row["teach_level"] || "intermediate",
      learn_level:        row["learn_level"] || "beginner",
      teach_category:     row["teach_category"] || "other",
      learn_category:     row["learn_category"] || "other",
      offer_hours:        (row["offer_hours"] || 1).to_i,
      modality:           normalize_modality.call(row["modality"]) || "remote",
      status:             (row["status"] || "open"),
      user:               user,
      created_at:         created_days_ago.zero? ? Time.current : created_days_ago.days.ago,
      expires_after_days: (row["expires_after_days"] || 30).to_i,
      availability_days:  parse_availability_days.call(row["availability_days"])
    }

    begin
      SkillExchangeRequest.create!(attrs)
    rescue ActiveRecord::RecordInvalid
      SkillExchangeRequest.new(attrs).save!(validate: false)
    end
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
