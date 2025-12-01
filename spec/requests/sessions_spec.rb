require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /login" do
    it "logs in with correct credentials and redirects to /explore" do
      user = User.create!(name: "K", email: "k@school.edu", password: "secretpass")

      post "/login", params: { email: user.email, password: "secretpass" }

      expect(response).to redirect_to("/explore")
      follow_redirect!
      expect(response.body).to include("Logged in successfully")
    end

    it "shows error on invalid credentials" do
      user = User.create!(name: "K", email: "k@school.edu", password: "secretpass")

      post "/login", params: { email: user.email, password: "wrong" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid email or password")
    end
  end

  describe "DELETE /logout" do
    it "clears session and redirects to root" do
      user = User.create!(name: "K", email: "k@school.edu", password: "secretpass")

      # log in
      post "/login", params: { email: user.email, password: "secretpass" }
      expect(session[:user_id]).to eq(user.id)

      delete "/logout"

      expect(response).to redirect_to("/")
      follow_redirect!
      expect(session[:user_id]).to 