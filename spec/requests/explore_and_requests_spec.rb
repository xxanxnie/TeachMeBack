require "rails_helper"

RSpec.describe "Explore and SkillExchangeRequests", type: :request do
  let(:user) { User.create!(email: "explorer@school.edu", password: "secretpass", name: "Explorer User") }
  let(:other_user) { User.create!(email: "poster@school.edu", password: "secretpass", name: "Poster User") }

  before do
    post "/login", params: { email: user.email, password: "secretpass" }
  end

  describe "GET /explore" do
    let!(:music_request) do
      SkillExchangeRequest.create!(
        user: other_user,
        teach_skill: "Guitar",
        teach_level: "intermediate",
        teach_category: "music_art",
        learn_skill: "Python",
        learn_level: "beginner",
        learn_category: "tech_academics",
        offer_hours: 2,
        modality: "remote",
        expires_after_days: 30,
        availability_days: [1],
        status: :open,
        created_at: 1.day.ago
      )
    end

    let!(:tech_request) do
      SkillExchangeRequest.create!(
        user: other_user,
        teach_skill: "JavaScript",
        teach_level: "beginner",
        teach_category: "tech_academics",
        learn_skill: "Singing",
        learn_level: "beginner",
        learn_category: "music_art",
        offer_hours: 3,
        modality: "in_person",
        expires_after_days: 20,
        availability_days: [2],
        status: :open,
        created_at: 2.days.ago
      )
    end

    it "loads explore page when logged in" do
      get "/explore"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Explore Skill Exchanges")
    end

    it "filters by role and category" do
      get "/explore", params: { role: ["student"], categories: ["music_art"] }
      expect(response.body).to include("Guitar")
      expect(response.body).not_to include("JavaScript")
    end

    it "filters by query intent" do
      get "/explore", params: { q: "teach guitar" }
      expect(response.body).to include("Guitar")
      expect(response.body).not_to include("JavaScript")
    end

    it "filters by availability days" do
      get "/explore", params: { days: ["tue"] }
      expect(response.body).to include("Guitar")
      expect(response.body).not_to include("JavaScript")
    end

    it "redirects guests to root" do
      delete "/logout"
      get "/explore"
      expect(response).to redirect_to(root_path)
    end
  end

  describe "SkillExchangeRequestsController" do
    it "creates a new request" do
      expect {
        post "/skill_exchange_requests", params: {
          skill_exchange_request: {
            teach_skill: "Banjo",
            teach_level: "beginner",
            teach_category: "music_art",
            learn_skill: "SQL",
            learn_level: "beginner",
            learn_category: "tech_academics",
            offer_hours: 2,
            modality: "remote",
            expires_after_days: 30,
            availability_days: [1]
          }
        }
      }.to change(SkillExchangeRequest, :count).by(1)

      expect(response).to redirect_to(explore_path)
    end

    it "renders errors when validation fails" do
      post "/skill_exchange_requests", params: {
        skill_exchange_request: {
          teach_skill: "",
          learn_skill: "",
          teach_level: "beginner",
          learn_level: "beginner",
          teach_category: "music_art",
          learn_category: "tech_academics",
          offer_hours: 2,
          modality: "remote",
          expires_after_days: 30,
          availability_days: []
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "allows expressing interest in another user's request" do
      ser = SkillExchangeRequest.create!(
        user: other_user,
        teach_skill: "Data Viz",
        teach_level: "beginner",
        teach_category: "tech_academics",
        learn_skill: "Piano",
        learn_level: "beginner",
        learn_category: "music_art",
        offer_hours: 1,
        modality: "remote",
        expires_after_days: 20,
        availability_days: [1],
        status: :open
      )

      post express_interest_skill_exchange_request_path(ser)
      expect(response).to redirect_to(explore_path).or redirect_to(message_thread_path(with: other_user.id))
      expect(UserSkillRequest.where(requester: user, receiver: other_user).count).to eq(1)
    end

    it "updates status to closed and redirects to review flow" do
      ser = SkillExchangeRequest.create!(
        user: user,
        teach_skill: "Cooking",
        teach_level: "beginner",
        teach_category: "other",
        learn_skill: "Guitar",
        learn_level: "beginner",
        learn_category: "music_art",
        offer_hours: 1,
        modality: "remote",
        expires_after_days: 15,
        availability_days: [0],
        status: :open
      )

      patch "/skill_exchange_requests/#{ser.id}", params: { skill_exchange_request: { status: :closed } }
      expect(response).to redirect_to(new_review_path(skill_exchange_request_id: ser.id))
    end

    it "forbids update by non-owner" do
      ser = SkillExchangeRequest.create!(
        user: other_user,
        teach_skill: "Knitting",
        teach_level: "beginner",
        teach_category: "other",
        learn_skill: "Piano",
        learn_level: "beginner",
        learn_category: "music_art",
        offer_hours: 1,
        modality: "remote",
        expires_after_days: 15,
        availability_days: [0],
        status: :open
      )

      patch "/skill_exchange_requests/#{ser.id}", params: { skill_exchange_request: { status: :closed } }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
