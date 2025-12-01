class ReviewsController < ApplicationController
  before_action :require_login
  before_action :set_request

  def new
    @match = find_match_for_request(@request, current_user)
    @reviewee = @match.other_user(current_user)
    @review = Review.new(skill_exchange_request: @request)
  end

  def create
    @match = find_match_for_request(@request, current_user)
    @reviewee = @match.other_user(current_user)

    @review = Review.new(review_params)
    @review.reviewer = current_user
    @review.reviewee = @reviewee
    @review.skill_exchange_request = @request
    @review.match = @match

    if @review.save
      @review.reviewee.update(avg_rating: @review.reviewee.received_reviews.average(:rating))
      respond_to do |format|
        format.html { redirect_to profile_path, notice: "Review submitted successfully!" }
        format.turbo_stream
      end
    else
      Rails.logger.debug "Review save failed: #{@review.errors.full_messages}"
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("review_form", partial: "reviews/form", locals: { review: @review }) }
      end
    end
  end

  private

  def set_request
    @request = SkillExchangeRequest.find(params[:skill_exchange_request_id])
  end

  def review_params
    params.require(:review).permit(:rating, :content)
  end

  def require_login
    redirect_to login_path, alert: "Please log in to leave a review." unless current_user
  end

  def find_match_for_request(request, current_user)
    user_ids = [request.user_id, request.partner_id].compact.sort
    Match.find_by(user1_id: user_ids.first, user2_id: user_ids.last) ||
      Match.find_by(user1_id: user_ids.last, user2_id: user_ids.first)
  end
end
