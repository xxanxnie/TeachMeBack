class ReviewsController < ApplicationController
  before_action :require_login
  def new
    @request = SkillExchangeRequest.find(params[:skill_exchange_request_id])
    @review = Review.new(skill_exchange_request: @request)
  end

  def create
    @request = SkillExchangeRequest.find(params[:skill_exchange_request_id])
    @review = Review.new(review_params)
    @review.reviewer = current_user
    @review.reviewee = @request.user
    @review.skill_exchange_request = @request

    if @review.save
      @review.reviewee.update(avg_rating: @review.reviewee.received_reviews.average(:rating))
      redirect_to profile_path, notice: "Review submitted successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :content)
  end

  def require_login
    unless current_user
      redirect_to login_path, alert: "Please log in to leave a review."
     end
  end
end
