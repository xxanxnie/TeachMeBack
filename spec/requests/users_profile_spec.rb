require "rails_helper"

RSpec.describe "User Profile", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@school.edu", password: "password123", first_name: "Test", last_name: "User") }

  before do
    post "/login", params: { email: user.email, password: "password123" }
  end

  describe "GET /profile" do
    context "when logged in" do
      it "returns http success" do
        get profile_path
        expect(response).to have_http_status(:success)
      end

      it "displays user's full name" do
        get profile_path
        expect(response.body).to include("Test User")
      end

      it "displays user's email" do
        get profile_path
        expect(response.body).to include(user.email)
      end

      it "displays email as read-only" do
        get profile_path
        expect(response.body).to match(/Email.*read.*only/i)
      end

      context "with bio" do
        before { user.update!(bio: "I love coding and teaching!") }

        it "displays user's bio" do
          get profile_path
          expect(response.body).to include("I love coding and teaching!")
        end
      end

      context "without bio" do
        it "displays placeholder text" do
          get profile_path
          expect(response.body).to include("No bio yet")
        end
      end

      context "with location and university" do
        before { user.update!(location: "Manhattan, NY", university: "Columbia University") }

        it "displays location" do
          get profile_path
          expect(response.body).to include("Manhattan, NY")
        end

        it "displays university" do
          get profile_path
          expect(response.body).to include("Columbia University")
        end
      end

      context "without location and university" do
        it "displays placeholder text for location" do
          get profile_path
          expect(response.body).to include("Add location")
        end

        it "displays placeholder text for university" do
          get profile_path
          expect(response.body).to include("Add university")
        end
      end

      context "with skill exchange requests" do
        let!(:request1) do
          SkillExchangeRequest.create!(
            user: user,
            teach_skill: "Guitar",
            teach_level: "intermediate",
            learn_skill: "Python",
            learn_level: "beginner",
            offer_hours: 5,
            modality: "in_person",
            expires_after_days: 30,
            availability_days: [1, 3],
            status: :open
          )
        end

        let!(:request2) do
          SkillExchangeRequest.create!(
            user: user,
            teach_skill: "JavaScript",
            teach_level: "advanced",
            learn_skill: "Photography",
            learn_level: "beginner",
            offer_hours: 10,
            modality: "remote",
            expires_after_days: 60,
            availability_days: [2, 4],
            status: :open
          )
        end

        let!(:completed_request) do
          SkillExchangeRequest.create!(
            user: user,
            teach_skill: "Cooking",
            teach_level: "intermediate",
            learn_skill: "Dancing",
            learn_level: "beginner",
            offer_hours: 3,
            modality: "hybrid",
            expires_after_days: 30,
            availability_days: [0],
            status: :closed
          )
        end

        it "displays skills the user can teach" do
          get profile_path
          expect(response.body).to include("Guitar")
          expect(response.body).to include("JavaScript")
        end

        it "displays active skill exchange requests" do
          get profile_path
          expect(response.body).to include("Active Skill Exchange Requests")
          expect(response.body).to include("Guitar")
          expect(response.body).to include("JavaScript")
        end

        it "displays completed exchanges" do
          get profile_path
          expect(response.body).to include("History / Past Exchanges")
          expect(response.body).to include("Cooking")
        end
      end

      context "without any skill exchange requests" do
        it "displays message about no skills" do
          get profile_path
          expect(response.body).to include("No skills listed yet")
        end

        it "displays message about no active requests" do
          get profile_path
          expect(response.body).to include("No active requests yet")
        end

        it "displays message about no past exchanges" do
          get profile_path
          expect(response.body).to include("No past exchanges yet")
        end
      end

      it "has link to create new request" do
        get profile_path
        expect(response.body).to include("Post a new skill exchange request")
      end
    end

    context "when not logged in" do
      it "redirects to root path" do
        delete "/logout"
        get profile_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /profile" do
    context "with valid parameters" do
      it "updates first name" do
        patch profile_path, params: { user: { first_name: "Updated" } }
        user.reload
        expect(user.first_name).to eq("Updated")
      end

      it "updates last name" do
        patch profile_path, params: { user: { last_name: "Name" } }
        user.reload
        expect(user.last_name).to eq("Name")
      end

      it "updates bio" do
        patch profile_path, params: { user: { bio: "Updated bio text" } }
        user.reload
        expect(user.bio).to eq("Updated bio text")
      end

      it "updates location" do
        patch profile_path, params: { user: { location: "New York, NY" } }
        user.reload
        expect(user.location).to eq("New York, NY")
      end

      it "updates university" do
        patch profile_path, params: { user: { university: "Columbia University" } }
        user.reload
        expect(user.university).to eq("Columbia University")
      end

      it "updates multiple fields at once" do
        patch profile_path, params: {
          user: {
            first_name: "John",
            last_name: "Doe",
            bio: "New bio",
            location: "Boston, MA",
            university: "MIT"
          }
        }
        user.reload
        expect(user.first_name).to eq("John")
        expect(user.last_name).to eq("Doe")
        expect(user.bio).to eq("New bio")
        expect(user.location).to eq("Boston, MA")
        expect(user.university).to eq("MIT")
      end

      it "redirects back to profile page" do
        patch profile_path, params: { user: { bio: "Updated bio" } }
        expect(response).to redirect_to(profile_path)
      end

      it "does not display success flash message" do
        patch profile_path, params: { user: { bio: "Updated bio" } }
        follow_redirect!
        expect(response.body).not_to include("updated successfully")
      end
    end

    context "with invalid parameters" do
      it "allows empty first_name (no validation on first_name alone)" do
        patch profile_path, params: { user: { first_name: "" } }
        user.reload
        expect(user.first_name).to be_blank
        expect(response).to redirect_to(profile_path)
      end

      it "updates bio even with long text (no length validation)" do
        long_bio = "a" * 1000
        patch profile_path, params: { user: { bio: long_bio } }
        user.reload
        expect(user.bio).to eq(long_bio)
      end
    end

    context "when not logged in" do
      it "redirects to root path" do
        delete "/logout"
        patch profile_path, params: { user: { bio: "Test" } }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

