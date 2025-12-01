require "rails_helper"
require 'shoulda/matchers'

RSpec.describe User, type: :model do
  it "is valid with name, .edu email, and password" do
    u = User.new(name: "Kiel", email: "k@school.edu", password: "secretpass")
    expect(u).to be_valid
    expect(u.edu_verified).to eq(true)
  end

  it "rejects non-.edu email and sets edu_verified false" do
    u = User.new(name: "Kiel", email: "k@gmail.com", password: "secretpass")
    expect(u).not_to be_valid
    expect(u.errors[:email]).to include(".edu email required")
    expect(u.edu_verified).to eq(false)
  end

  it "requires a name" do
    u = User.new(email: "k@school.edu", password: "secretpass")
    expect(u).not_to be_valid
    expect(u.errors[:name]).to be_present
  end
end

describe "review associations (functional)" do
  it "returns reviews where user is the reviewee" do
    bob = User.create!(email: "bob@school.edu", password: "pass123", name: "Bob")
    alice = User.create!(email: "alice@school.edu", password: "pass123", name: "Alice")

    request = SkillExchangeRequest.create!(
      user: bob,
      teach_skill: "Ruby",
      learn_skill: "Python",
      expires_after_days: 7,
      availability_days: ["Monday"]
    )

    review = Review.create!(
      rating: 5,
      content: "Great job!",
      reviewer: alice,
      reviewee: bob,
      skill_exchange_request: request
    )

    expect(bob.received_reviews).to include(review)
    expect(alice.given_reviews).to include(review)
  end
end

describe "#avg_rating" do
  it "returns the correct average from received reviews" do
    user = User.create!(email: "bob@school.edu", password: "pass123", name: "Bob")
    reviewer1 = User.create!(email: "a@school.edu", password: "pass123", name: "Alice")
    reviewer2 = User.create!(email: "c@school.edu", password: "pass123", name: "Charlie")

    request = SkillExchangeRequest.create!(
      user: user,
      teach_skill: "Ruby",
      learn_skill: "Python",
      expires_after_days: 7,
      availability_days: ["Monday"]
    )

    Review.create!(rating: 4, content: "Good", reviewer: reviewer1, reviewee: user, skill_exchange_request: request)
    Review.create!(rating: 5, content: "Great", reviewer: reviewer2, reviewee: user, skill_exchange_request: request)

    user.update(avg_rating: user.received_reviews.average(:rating))

    expect(user.avg_rating).to eq(4.5)
  end
end


