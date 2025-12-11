require 'rails_helper'

RSpec.describe "Reviews", type: :request do
  let(:user) { User.create!(email: "a@uni.edu", password: "secretpass", name: "Alice") }
  let(:partner) { User.create!(email: "b@uni.edu", password: "secretpass", name: "Bob") }
  let(:request_record) do
    SkillExchangeRequest.create!(
      user: partner,
      teach_skill: "Ruby",
      teach_level: "beginner",
      teach_category: "tech_academics",
      learn_skill: "Python",
      learn_level: "beginner",
      learn_category: "language",
      offer_hours: 2,
      modality: "remote",
      expires_after_days: 7,
      availability_days: [1]
    )
  end

  before do
    post "/login", params: { email: user.email, password: "secretpass" }
  end

  describe "GET /new" do
    it "returns http success" do
      get "/reviews/new", params: { skill_exchange_request_id: request_record.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a review and redirects" do
      post "/reviews", params: {
        skill_exchange_request_id: request_record.id,
        reviewee_id: partner.id,
        review: { rating: 5, content: "Nice chat" }
      }

      expect(response).to redirect_to(profile_path)
      expect(Review.count).to eq(1)
    end
  end

end
