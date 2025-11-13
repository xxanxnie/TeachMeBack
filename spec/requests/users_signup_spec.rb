require "rails_helper"

RSpec.describe "User Signup", type: :request do
  describe "GET /signup" do
    it "returns http success" do
      get signup_path
      expect(response).to have_http_status(:success)
    end

    it "displays signup form" do
      get signup_path
      expect(response.body).to include("Create your account")
      expect(response.body).to include("First name")
      expect(response.body).to include("Last name")
      expect(response.body).to include("School / University")
      expect(response.body).to include("Email")
      expect(response.body).to include("Password")
    end
  end

  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          first_name: "John",
          last_name: "Doe",
          university: "Columbia University",
          email: "john.doe@school.edu",
          password: "password123"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post users_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "sets user attributes correctly" do
        post users_path, params: valid_params
        user = User.last
        expect(user.first_name).to eq("John")
        expect(user.last_name).to eq("Doe")
        expect(user.university).to eq("Columbia University")
        expect(user.email).to eq("john.doe@school.edu")
      end

      it "verifies email as .edu" do
        post users_path, params: valid_params
        user = User.last
        expect(user.edu_verified).to be true
      end

      it "sets name from first and last name" do
        post users_path, params: valid_params
        user = User.last
        expect(user.name).to eq("John Doe")
      end

      it "redirects to login page" do
        post users_path, params: valid_params
        expect(response).to redirect_to(login_path)
      end

      it "shows success message" do
        post users_path, params: valid_params
        follow_redirect!
        expect(response.body).to include("Account created successfully")
      end
    end

    context "with invalid parameters" do
      it "does not create user without email" do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:email] = ""
        
        expect {
          post users_path, params: invalid_params
        }.not_to change(User, :count)
      end

      it "does not create user with non-.edu email" do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:email] = "john@gmail.com"
        
        expect {
          post users_path, params: invalid_params
        }.not_to change(User, :count)
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(".edu email required")
      end

      it "does not create user without password" do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:password] = ""
        
        expect {
          post users_path, params: invalid_params
        }.not_to change(User, :count)
      end

      it "re-renders signup form with errors" do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:email] = ""
        
        post users_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Create your account")
      end
    end
  end
end

