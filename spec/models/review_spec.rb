require 'rails_helper'

RSpec.describe Review, type: :model do
  describe "validations" do
    it "is valid with rating, content, reviewer, and reviewee" do
      reviewer = User.create!(email: "a@uni.edu", password: "secretpass", name: "Alice")
      reviewee = User.create!(email: "b@uni.edu", password: "secretpass", name: "Bob")
      request = SkillExchangeRequest.create!(
        user: reviewee,
        teach_skill: "Ruby",
        teach_level: "beginner",
        teach_category: "tech_academics",
        learn_skill: "Python",
        learn_level: "beginner",
        learn_category: "language",
        offer_hours: 2,
        modality: "remote",
        expires_after_days: 7,
        availability_days: ["Monday", "Wednesday"]
      )

      review = Review.new(
        rating: 4,
        content: "Great session!",
        reviewer: reviewer,
        reviewee: reviewee,
        skill_exchange_request: request
      )

      expect(review).to be_valid
    end

    it "is invalid without a rating" do
      review = Review.new(rating: nil)
      review.validate
      expect(review.errors[:rating]).to include("can't be blank")
    end

    it "is invalid without a reviewer" do
      review = Review.new(reviewer: nil)
      review.validate
      expect(review.errors[:reviewer]).to include("must exist")
    end

    it "is invalid without a reviewee" do
      review = Review.new(reviewee: nil)
      review.validate
      expect(review.errors[:reviewee]).to include("must exist")
    end
  end

  describe "associations" do
    it { should belong_to(:reviewer).class_name("User") }
    it { should belong_to(:reviewee).class_name("User") }
    it { should belong_to(:skill_exchange_request) }
  end
end
