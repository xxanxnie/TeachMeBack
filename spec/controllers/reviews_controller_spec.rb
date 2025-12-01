require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  let(:reviewer) { User.create!(email: "a@uni.edu", password: "secretpass", name: "Alice") }
  let(:reviewee) { User.create!(email: "b@uni.edu", password: "secretpass", name: "Bob") }
  let(:request) do
    SkillExchangeRequest.create!(
      user: reviewee,
      teach_skill: "Ruby",
      learn_skill: "Python",
      expires_after_days: 7,
      availability_days: ["Monday", "Wednesday"]
    )
  end

  before do
    session[:user_id] = reviewer.id
  end

  describe "GET #new" do
    it "renders the review form" do
      get :new, params: { skill_exchange_request_id: request.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:review)).to be_a_new(Review)
    end
  end

  describe "POST #create" do
    context "with valid data" do
      it "creates a review and updates avg_rating" do
        post :create, params: {
          skill_exchange_request_id: request.id,
          review: {
            rating: 5,
            content: "Excellent!",
            reviewee_id: reviewee.id
          }
        }

        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to eq("Review submitted successfully!")

        reviewee.reload
        expect(reviewee.avg_rating).to eq(5.0)
        expect(Review.count).to eq(1)
      end
    end

    context "with invalid data" do
      it "does not save and re-renders the form" do
        post :create, params: {
          skill_exchange_request_id: request.id,
          review: {
            rating: nil,
            content: "",
            reviewee_id: reviewee.id
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(assigns(:review).errors[:rating]).to include("can't be blank")
      end
    end
  end
end
