require "rails_helper"

RSpec.describe "Controller coverage", type: :request do
  let(:user) { User.create!(email: "user@school.edu", password: "secretpass", name: "User One", first_name: "User", last_name: "One") }
  let(:other_user) { User.create!(email: "other@school.edu", password: "secretpass", name: "Other User", first_name: "Other", last_name: "User") }

  before do
    post "/login", params: { email: user.email, password: "secretpass" }
  end

  describe "MatchController#index" do
    let!(:match) { Match.create!(user1: user, user2: other_user, status: "mutual") }
    let!(:outgoing) { UserSkillRequest.create!(requester: user, receiver: other_user, skill: "Guitar") }
    let!(:incoming) { UserSkillRequest.create!(requester: other_user, receiver: user, skill: "Python") }

    it "loads matches and details" do
      get "/match"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Match")
    end
  end

  describe "MessagesController" do
    let!(:partner) { other_user }

    it "shows an empty inbox" do
      get "/messages"
      expect(response).to have_http_status(:success)
    end

    it "renders a thread and marks read" do
      Message.create!(sender: partner, recipient: user, body: "hello")
      get "/messages/thread", params: { with: partner.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("hello")
    end

    it "creates a message and redirects to thread" do
      post "/messages", params: { message: { recipient_id: partner.id, body: "ping" } }
      expect(response).to redirect_to(message_thread_path(with: partner.id))
      expect(Message.where(body: "ping").count).to eq(1)
    end
  end

  describe "UserSkillRequestsController#create" do
    let!(:skill_request) do
      SkillExchangeRequest.create!(
        user: other_user,
        teach_skill: "Drums",
        teach_level: "beginner",
        teach_category: "music_art",
        learn_skill: "Rails",
        learn_level: "beginner",
        learn_category: "tech_academics",
        offer_hours: 2,
        modality: "remote",
        expires_after_days: 30,
        availability_days: [3],
        status: :open
      )
    end

    it "creates a new request" do
      post "/user_skill_requests", params: { receiver_id: other_user.id, skill_exchange_request_id: skill_request.id, skill: "Drums" }
      expect(response).to redirect_to(explore_path).or redirect_to(message_thread_path(with: other_user.id))
      expect(UserSkillRequest.count).to eq(1)
    end

    it "redirects to thread when match already exists" do
      Match.create!(user1: user, user2: other_user, status: "mutual")
      post "/user_skill_requests", params: { receiver_id: other_user.id, skill_exchange_request_id: skill_request.id, skill: "Drums" }
      expect(response).to redirect_to(message_thread_path(with: other_user.id))
    end
  end

  describe "SkillExchangeRequestsController#express_interest" do
    let!(:own_request) do
      SkillExchangeRequest.create!(
        user: user,
        teach_skill: "Piano",
        teach_level: "beginner",
        teach_category: "music_art",
        learn_skill: "SQL",
        learn_level: "beginner",
        learn_category: "tech_academics",
        offer_hours: 1,
        modality: "remote",
        expires_after_days: 30,
        availability_days: [0]
      )
    end

    it "prevents expressing interest in own request" do
      post express_interest_skill_exchange_request_path(own_request)
      expect(response).to redirect_to(explore_path)
    end
  end
end

RSpec.describe DashboardController, type: :controller do
  routes do
    ActionDispatch::Routing::RouteSet.new.tap do |r|
      r.draw do
        root to: redirect("/")
        get "/dashboard" => "dashboard#index"
      end
    end
  end

  let(:user) { User.create!(email: "user@school.edu", password: "secretpass", name: "User One") }
  let(:other_user) { User.create!(email: "other@school.edu", password: "secretpass", name: "Other User") }

  let!(:fresh_request) do
    SkillExchangeRequest.create!(
      user: other_user,
      teach_skill: "Guitar",
      teach_level: "beginner",
      teach_category: "music_art",
      learn_skill: "Python",
      learn_level: "beginner",
      learn_category: "tech_academics",
      offer_hours: 2,
      modality: "remote",
      expires_after_days: 30,
      availability_days: [1],
      status: :open,
      created_at: 2.days.ago
    )
  end

  let!(:expired_request) do
    SkillExchangeRequest.create!(
      user: other_user,
      teach_skill: "Old Skill",
      teach_level: "beginner",
      teach_category: "other",
      learn_skill: "Old Learn",
      learn_level: "beginner",
      learn_category: "other",
      offer_hours: 1,
      modality: "remote",
      expires_after_days: 7,
      availability_days: [2],
      status: :open,
      created_at: 200.days.ago
    )
  end

  it "redirects when not logged in" do
    get :index
    expect(response).to have_http_status(:redirect)
  end

  it "renders and filters expired when logged in" do
    session[:user_id] = user.id
    get :index
    expect(response).to have_http_status(:success)
    expect(assigns(:skill_requests)).to include(fresh_request)
    expect(assigns(:skill_requests)).not_to include(expired_request)
  end
end
