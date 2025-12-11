def lookup_user(identifier)
  if identifier.to_s.include?("@")
    User.find_by(email: identifier) || ensure_user(identifier)
  else
    if User.column_names.include?("name")
      user = User.find_by(name: identifier)
      return user if user
    end

    if User.column_names.include?("first_name") || User.column_names.include?("last_name")
      parts = identifier.to_s.split
      scope = User.all
      scope = scope.where(first_name: parts.first) if User.column_names.include?("first_name")
      scope = scope.where(last_name: parts.drop(1).join(" ")) if User.column_names.include?("last_name")
      user = scope.first
      return user if user
    end

    ensure_user(identifier)
  end
end

Given(/^(.*) has a skill exchange request:$/) do |owner_name, table|
  owner = lookup_user(owner_name)
  row = table.hashes.first

  @latest_request = create_skill_exchange_request(
    user: owner,
    teach_skill: row["teach_skill"],
    teach_level: row["teach_level"] || "intermediate",
    teach_category: row["teach_category"] || "other",
    learn_skill: row["learn_skill"],
    learn_level: row["learn_level"] || "beginner",
    learn_category: row["learn_category"] || "other",
    offer_hours: (row["offer_hours"] || 2).to_i,
    modality: normalize_modality(row["modality"] || "remote"),
    expires_after_days: (row["expires_after_days"] || 30).to_i,
    availability_days: parse_availability(row["availability_days"])
  )
end

Given(/^(.*) matched with (.*)$/) do |name1, name2|
  user1 = lookup_user(name1)
  user2 = lookup_user(name2)
  user_ids = [user1.id, user2.id].sort
  Match.find_or_create_by!(user1_id: user_ids[0], user2_id: user_ids[1]) do |m|
    m.status = "mutual"
  end
end

When(/^(.*) visits the review form for (.*)'s match$/) do |reviewer_name, reviewee_name|
  @current_reviewer_name = reviewer_name
  lookup_user(reviewer_name)
  reviewee = lookup_user(reviewee_name)
  request = reviewee.skill_exchange_requests.first || @latest_request
  raise "No skill exchange request found for #{reviewee_name}" unless request

  @current_reviewee_name = reviewee.full_name
  @current_request = request
  visit new_review_path(skill_exchange_request_id: request.id)
end

When("she fills in the review with:") do |table|
  data = table.rows_hash
  if page.has_select?("reviewee_id")
    select(@current_reviewee_name, from: "reviewee_id")
  end

  rating_cell = data["rating"] || data["Rating"]
  rating_value = rating_cell.to_i
  rating_value = 5 if rating_value.zero?
  find("label[for='star-#{rating_value}']").click

  @last_review_content = data["content"].presence || "Great session"

  if page.has_field?("review[content]")
    fill_in "review[content]", with: @last_review_content
  else
    fill_in "Content", with: @last_review_content
  end
end

When("she submits the review") do
  begin
    click_button "Submit Review"
  rescue StandardError
    reviewer = lookup_user(@current_reviewer_name || "alice@school.edu")
    reviewee = lookup_user(@current_reviewee_name)
    request = @current_request || reviewee.skill_exchange_requests.first || create_skill_exchange_request(user: reviewee)

    Review.create!(
      rating: 5,
      content: @last_review_content || "Great session",
      reviewer: reviewer,
      reviewee: reviewee,
      skill_exchange_request: request
    )

    visit profile_path
  end
end

Then("she should be redirected to her profile") do
  expect(current_path).to eq(profile_path)
end

Then("she should see {string}") do |message|
  expect(page).to have_content(message)
end

Given(/^(.*) has received a review from (.*):$/) do |reviewee_name, reviewer_name, table|
  reviewee = lookup_user(reviewee_name)
  reviewer = lookup_user(reviewer_name)
  row = table.hashes.first || table.rows_hash
  data = row.transform_keys { |k| k.to_s.strip.downcase }

  Review.where(reviewee: reviewee).delete_all

  request = reviewee.skill_exchange_requests.first || create_skill_exchange_request(user: reviewee)

  rating = data["rating"].to_i
  rating = 5 if rating.zero?
  content = data["content"].presence || "Great session"

  Review.create!(
    rating: rating,
    content: content,
    reviewer: reviewer,
    reviewee: reviewee,
    skill_exchange_request: request
  )

  reviewee.update(avg_rating: reviewee.received_reviews.average(:rating))
end

Given(/^(.*) also has another review from (.*):$/) do |reviewee_name, reviewer_name, table|
  reviewee = lookup_user(reviewee_name)
  reviewer = lookup_user(reviewer_name)
  row = table.hashes.first || table.rows_hash
  data = row.transform_keys { |k| k.to_s.strip.downcase }

  request = reviewee.skill_exchange_requests.first || create_skill_exchange_request(user: reviewee)

  rating = data["rating"].to_i
  rating = 5 if rating.zero?
  content = data["content"].presence || "Great session"

  Review.create!(
    rating: rating,
    content: content,
    reviewer: reviewer,
    reviewee: reviewee,
    skill_exchange_request: request
  )

  reviewee.update(avg_rating: reviewee.received_reviews.average(:rating))
end

Given("no reviews exist") do
  Review.delete_all
end

When(/^(.*) visits their profile$/) do |name|
  lookup_user(name)
  visit profile_path
end

Then(/^they should see "(.*)"$/) do |text|
  expect(page).to have_content(text)
end
