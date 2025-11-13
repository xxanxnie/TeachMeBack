require 'rails_helper'

RSpec.describe "Navbar", type: :request do
  it "hides logout for guests" do
    get root_path
    expect(response.body).not_to include("Logout")
  end

  it "shows logout for logged in users" do
    user = User.create!(name: "Test", email: "test@school.edu", password: "password")
    post login_path, params: { email: user.email, password: "password" }
    follow_redirect!
    expect(response.body).to include("Logout")
  end
end
