require "rails_helper"

RSpec.describe "SkillExchangeRequests", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@school.edu", password: "password123", first_name: "Test", last_name: "User") }

  before do
    post "/login", params: { email: user.email, password: "password123" }
  end

  describe "GET /skill_exchange_requests/new" do
    it "returns http success" do
      get new_skill_exchange_request_path
      expect(response).to have_http_status(:success)
    end

    it "assigns a new skill exchange request" do
      get new_skill_exchange_request_path
      expect(assigns(:skill_exchange_request)).to be_a_new(SkillExchangeRequest)
      expect(assigns(:skill_exchange_request)).to be_new_record
    end
  end

  describe "POST /skill_exchange_requests" do
    let(:valid_params) do
      {
        skill_exchange_request: {
          teach_skill: "Guitar",
          teach_level: "intermediate",
          teach_category: "music_art",
          learn_skill: "Python",
          learn_level: "beginner",
          learn_category: "tech_academics",
          offer_hours: 5,
          modality: "in_person",
          expires_after_days: 30,
          availability_days: [1, 3, 5], # Tue, Thu, Sat
          learning_goal: "Build a web app",
          notes: "Prefer evenings"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new skill exchange request" do
        expect {
          post skill_exchange_requests_path, params: valid_params
        }.to change(SkillExchangeRequest, :count).by(1)
      end

      it "redirects to explore page with success message" do
        post skill_exchange_requests_path, params: valid_params
        expect(response).to redirect_to(explore_path)
        follow_redirect!
        expect(response.body).to include("Posted.")
      end

      it "sets the correct attributes" do
        post skill_exchange_requests_path, params: valid_params
        request = SkillExchangeRequest.last
        expect(request.teach_skill).to eq("Guitar")
        expect(request.learn_skill).to eq("Python")
        expect(request.teach_level).to eq("intermediate")
        expect(request.learn_level).to eq("beginner")
        expect(request.offer_hours).to eq(5)
        expect(request.modality).to eq("in_person")
        expect(request.expires_after_days).to eq(30)
        expect(request.learning_goal).to eq("Build a web app")
        expect(request.notes).to eq("Prefer evenings")
      end

      it "associates the request with the current user" do
        post skill_exchange_requests_path, params: valid_params
        request = SkillExchangeRequest.last
        expect(request.user).to eq(user)
      end

      it "sets availability days correctly" do
        post skill_exchange_requests_path, params: valid_params
        request = SkillExchangeRequest.last
        expect(request.availability_days).to match_array([1, 3, 5])
      end

      it "normalizes skill names by stripping whitespace" do
        params_with_spaces = valid_params.deep_dup
        params_with_spaces[:skill_exchange_request][:teach_skill] = "  Guitar  "
        params_with_spaces[:skill_exchange_request][:learn_skill] = "  Python  "
        
        post skill_exchange_requests_path, params: params_with_spaces
        request = SkillExchangeRequest.last
        expect(request.teach_skill).to eq("Guitar")
        expect(request.learn_skill).to eq("Python")
      end
    end

    context "with invalid parameters" do
      it "does not create a request when teach_skill is missing" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request][:teach_skill] = ""
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Teach skill")
      end

      it "does not create a request when learn_skill is missing" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request][:learn_skill] = ""
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a request when no availability days are selected" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request].delete(:availability_days)
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to match(/at least one day/)
      end

      it "does not create a request when offer_hours is too high" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request][:offer_hours] = 50
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a request when offer_hours is zero" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request][:offer_hours] = 0
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a request when expires_after_days is too low" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request][:expires_after_days] = 5
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a request when expires_after_days is too high" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request][:expires_after_days] = 200
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a request when modality is invalid" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request][:modality] = "invalid"
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a request when learning_goal is too long" do
        invalid_params = valid_params.deep_dup
        invalid_params[:skill_exchange_request][:learning_goal] = "a" * 501
        
        expect {
          post skill_exchange_requests_path, params: invalid_params
        }.not_to change(SkillExchangeRequest, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with different modalities" do
      it "creates a request with remote modality" do
        params = valid_params.deep_dup
        params[:skill_exchange_request][:modality] = "remote"
        
        post skill_exchange_requests_path, params: params
        expect(SkillExchangeRequest.last.modality).to eq("remote")
      end

      it "creates a request with hybrid modality" do
        params = valid_params.deep_dup
        params[:skill_exchange_request][:modality] = "hybrid"
        
        post skill_exchange_requests_path, params: params
        expect(SkillExchangeRequest.last.modality).to eq("hybrid")
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        delete "/logout"
        post skill_exchange_requests_path, params: valid_params
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /skill_exchange_requests/:id" do
    let(:skill_request) do
      SkillExchangeRequest.create!(
        user: user,
        teach_skill: "Guitar",
        teach_level: "intermediate",
        teach_category: "music_art",
        learn_skill: "Python",
        learn_level: "beginner",
        learn_category: "tech_academics",
        offer_hours: 5,
        modality: "in_person",
        expires_after_days: 30,
        availability_days: [1, 3]
      )
    end

    it "shows the skill exchange request" do
      get skill_exchange_request_path(skill_request)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Guitar")
      expect(response.body).to include("Python")
    end

    it "renders another user's request (public view)" do
      other_user = User.create!(name: "Other", email: "other@school.edu", password: "password123")
      other_request = SkillExchangeRequest.create!(
        user: other_user,
        teach_skill: "Guitar",
        teach_level: "intermediate",
        teach_category: "music_art",
        learn_skill: "Python",
        learn_level: "beginner",
        learn_category: "tech_academics",
        offer_hours: 5,
        modality: "in_person",
        expires_after_days: 30,
        availability_days: [1]
      )
      
      get skill_exchange_request_path(other_request)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Guitar")
    end
  end

  describe "GET /requests" do
    let!(:request1) { SkillExchangeRequest.create!(user: user, teach_skill: "Guitar", teach_level: "intermediate", teach_category: "music_art", learn_skill: "Python", learn_level: "beginner", learn_category: "tech_academics", offer_hours: 5, modality: "in_person", expires_after_days: 30, availability_days: [1, 3]) }
    let!(:request2) { SkillExchangeRequest.create!(user: user, teach_skill: "Cooking", teach_level: "advanced", teach_category: "other", learn_skill: "Spanish", learn_level: "beginner", learn_category: "language", offer_hours: 3, modality: "remote", expires_after_days: 60, availability_days: [0, 2]) }

    it "returns http success" do
      get "/requests"
      expect(response).to have_http_status(:success)
    end

    it "displays all skill exchange requests" do
      get "/requests"
      expect(response.body).to include("Guitar")
      expect(response.body).to include("Python")
      expect(response.body).to include("Cooking")
      expect(response.body).to include("Spanish")
    end
  end
end
