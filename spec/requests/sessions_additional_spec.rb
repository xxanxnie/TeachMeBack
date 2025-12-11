require "rails_helper"

RSpec.describe "Sessions extra coverage", type: :request do
  let!(:user) { User.create!(email: "login@school.edu", password: "secretpass", name: "Login User") }

  it "renders login form" do
    get "/login"
    expect(response).to have_http_status(:success)
  end

  it "renders new template on invalid credentials" do
    post "/login", params: { email: user.email, password: "wrong" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Invalid email or password")
  end

  it "renders home page when invalid from home auth_source" do
    post "/login", params: { email: user.email, password: "wrong", auth_source: "home" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Log in")
  end
end
