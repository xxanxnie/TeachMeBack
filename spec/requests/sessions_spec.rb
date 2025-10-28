require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /login" do
    it "logs in with correct credentials and redirects to /dashboard" do
      user = User.create!(name: "K", email: "k@school.edu", password: "secret")
      post "/login", params: { email: user.email, password: "secret" }
      expect(response).to redirect_to("/dashboard")
      follow_redirect!
      expect(response.body).to include("Welcome back")
    end

    it "shows error on invalid credentials" do
      user = User.create!(name: "K", email: "k@school.edu", password: "secret")
      post "/login", params: { email: user.email, password: "wrong" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Invalid email or password")
    end
  end

  describe "DELETE /logout" do
    it "clears session and redirects to root with notice" do
      user = User.create!(name: "K", email: "k@school.edu", password: "secret")
      # log in
      post "/login", params: { email: user.email, password: "secret" }
      expect(session[:user_id]).to eq(user.id)

      delete "/logout"
      expect(response).to redirect_to("/")
      follow_redirect!
      expect(response.body).to include("Signed out")
      expect(session[:user_id]).to be_nil
    end
  end
end

