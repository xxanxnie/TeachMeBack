Given("Alice matched with Bob") do
  alice = User.find_by(name: "Alice")
  bob = User.find_by(name: "Bob")
  request = SkillExchangeRequest.find_by(user: bob)
  Match.create!(user: alice, skill_exchange_request: request)
end

When("Alice visits the review form for Bob's match") do
  request = SkillExchangeRequest.find_by(user: User.find_by(name: "Bob"))
  visit new_review_path(skill_exchange_request_id: request.id)
end

When("she fills in the review with:") do |table|
  data = table.rows_hash
  select data["rating"], from: "Rating"
  fill_in "Content", with: data["content"]
end

When("she submits the review") do
  click_button "Submit Review"
end

Then("she should be redirected to her profile") do
  expect(current_path).to eq(profile_path)
end

Then("she should see {string}") do |message|
  expect(page).to have_content(message)
end

Given("Bob is logged in") do
  visit login_path
  fill_in "Email", with: "bob@school.edu"
  fill_in "Password", with: "secret"
  click_button "Log in"
end

Given("Bob has received a review from Alice:") do |table|
  data = table.rows_hash
  alice = User.find_by(name: "Alice")
  bob = User.find_by(name: "Bob")

  request = SkillExchangeRequest.create!(
    user: bob,
    teach_skill: "Ruby",
    learn_skill: "Python",
    expires_after_days: 7,
    availability_days: ["Monday"]
  )

  Review.create!(
    rating: data["rating"],
    content: data["content"],
    reviewer: alice,
    reviewee: bob,
    skill_exchange_request: request
  )

  bob.update(avg_rating: bob.received_reviews.average(:rating))
end

When("Bob visits their profile") do
  visit profile_path
end

Then("they should see {string}") do |text|
  expect(page).to have_content(text)
end
