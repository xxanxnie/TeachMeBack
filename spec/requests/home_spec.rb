require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "displays TeachMeBack title" do
      get root_path
      expect(response.body).to include("TeachMeBack")
    end

    it "displays tagline" do
      get root_path
      expect(response.body).to include("Turning Campus Talent Into Shared Learning")
    end

    it "displays signup link" do
      get root_path
      expect(response.body).to include("Create account to get started")
    end

    it "displays login form" do
      get root_path
      expect(response.body).to include("Log in")
      expect(response.body).to include("Email")
      expect(response.body).to include("Password")
    end
  end
end

