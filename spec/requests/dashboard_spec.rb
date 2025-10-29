require "rails_helper"

RSpec.describe "Dashboard (Explore)", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@school.edu", password: "password123", first_name: "Test", last_name: "User") }
  let(:other_user) { User.create!(name: "Alice Smith", email: "alice@school.edu", password: "password123", first_name: "Alice", last_name: "Smith") }

  before do
    post "/login", params: { email: user.email, password: "password123" }
  end

  describe "GET /explore" do
    context "when logged in" do
      let!(:open_request1) do
        SkillExchangeRequest.create!(
          user: other_user,
          teach_skill: "Guitar",
          teach_level: "intermediate",
          learn_skill: "Python",
          learn_level: "beginner",
          offer_hours: 5,
          modality: "in_person",
          expires_after_days: 30,
          availability_days: [1, 3],
          status: :open,
          created_at: 10.days.ago
        )
      end

      let!(:open_request2) do
        SkillExchangeRequest.create!(
          user: other_user,
          teach_skill: "JavaScript",
          teach_level: "advanced",
          learn_skill: "Photography",
          learn_level: "beginner",
          offer_hours: 10,
          modality: "remote",
          expires_after_days: 60,
          availability_days: [2, 4],
          status: :open,
          created_at: 5.days.ago
        )
      end

      let!(:closed_request) do
        SkillExchangeRequest.create!(
          user: other_user,
          teach_skill: "Dancing",
          teach_level: "intermediate",
          learn_skill: "Cooking",
          learn_level: "beginner",
          offer_hours: 3,
          modality: "hybrid",
          expires_after_days: 30,
          availability_days: [0],
          status: :closed,
          created_at: 1.day.ago
        )
      end

      let!(:expired_request) do
        SkillExchangeRequest.create!(
          user: other_user,
          teach_skill: "Math",
          teach_level: "advanced",
          learn_skill: "Art",
          learn_level: "beginner",
          offer_hours: 2,
          modality: "in_person",
          expires_after_days: 10,
          availability_days: [1],
          status: :open,
          created_at: 11.days.ago
        )
      end

      let!(:old_request) do
        SkillExchangeRequest.create!(
          user: other_user,
          teach_skill: "Old Skill",
          teach_level: "beginner",
          learn_skill: "Old Learn",
          learn_level: "beginner",
          offer_hours: 1,
          modality: "in_person",
          expires_after_days: 30,
          availability_days: [1],
          status: :open,
          created_at: 200.days.ago
        )
      end

      it "returns http success" do
        get explore_path
        expect(response).to have_http_status(:success)
      end

      it "displays only open requests" do
        get explore_path
        expect(response.body).to include("Guitar")
        expect(response.body).to include("JavaScript")
        expect(response.body).not_to include("Dancing") # closed request
      end

      it "filters out expired requests" do
        get explore_path
        expect(response.body).not_to include("Math") # expired request
      end

      it "filters out requests older than 180 days" do
        get explore_path
        expect(response.body).not_to include("Old Skill")
      end

      it "orders requests by most recent first" do
        get explore_path
        body = response.body
        js_index = body.index("JavaScript")
        guitar_index = body.index("Guitar")
        expect(js_index).to be < guitar_index if js_index && guitar_index
      end

      context "with search query" do
        it "filters by teach_skill" do
          get explore_path, params: { q: "guitar" }
          expect(response.body).to include("Guitar")
          expect(response.body).not_to include("JavaScript")
        end

        it "filters by learn_skill" do
          get explore_path, params: { q: "python" }
          expect(response.body).to include("Guitar")
          expect(response.body).not_to include("JavaScript")
        end

        it "filters by user name" do
          get explore_path, params: { q: "alice" }
          expect(response.body).to include("Guitar")
          expect(response.body).to include("JavaScript")
        end

        it "filters by modality" do
          get explore_path, params: { q: "remote" }
          expect(response.body).to include("JavaScript")
          expect(response.body).not_to include("Guitar")
        end

        it "is case insensitive" do
          get explore_path, params: { q: "GUITAR" }
          expect(response.body).to include("Guitar")
        end

        it "handles partial matches" do
          get explore_path, params: { q: "java" }
          expect(response.body).to include("JavaScript")
        end

        it "returns empty results for no matches" do
          get explore_path, params: { q: "nonexistent" }
          expect(response.body).not_to include("Guitar")
          expect(response.body).not_to include("JavaScript")
        end

        it "handles empty query string" do
          get explore_path, params: { q: "" }
          expect(response.body).to include("Guitar")
          expect(response.body).to include("JavaScript")
        end

        it "handles query with only whitespace" do
          get explore_path, params: { q: "   " }
          expect(response.body).to include("Guitar")
          expect(response.body).to include("JavaScript")
        end
      end

    end

    context "when not logged in" do
      it "redirects to root path" do
        delete "/logout"
        get explore_path
        expect(response).to redirect_to(root_path)
      end

      it "shows alert message" do
        delete "/logout"
        get explore_path
        follow_redirect!
        expect(response.body).to include("Please log in")
      end
    end
  end
end

