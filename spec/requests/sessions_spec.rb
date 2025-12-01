require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "renders the login page" do
      get "/login"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    let!(:user) do
      User.create!(
        email: "test@school.edu",
        password: "secretpass",
        name: "Test User"
      )
    end

    it "logs the user in with valid credentials" do
      post "/login", params: { email: user.email, password: "secretpass" }
      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to("/explore")
    end
  end

  describe "DELETE /logout" do
    let!(:user) do
      User.create!(
        email: "logout-test@school.edu",
        password: "secretpass",
        name: "Logout User"
      )
    end

    before do
      post "/login", params: { email: user.email, password: "secretpass" }
      expect(session[:user_id]).to eq(user.id)
    end

    it "clears session and redirects to root" do
      delete "/logout"
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to("/")
    end
  end
end

