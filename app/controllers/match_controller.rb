class MatchController < ApplicationController
  before_action :require_login

  def index
    @loading = true
    @matches = current_user.matches.includes(:user1, :user2)
    @match_details = {}

    @matches.each do |match|
      other = match.other_user(current_user)
      pair_requests = UserSkillRequest.includes(:skill_exchange_request).where(
        requester_id: [current_user.id, other.id],
        receiver_id: [current_user.id, other.id]
      )

      mine   = pair_requests.where(requester_id: current_user.id, receiver_id: other.id).order(created_at: :desc).first
      theirs = pair_requests.where(requester_id: other.id, receiver_id: current_user.id).order(created_at: :desc).first

      @match_details[match.id] = { mine: mine, theirs: theirs }
    end
  end

  private

  def require_login
    unless current_user
      redirect_to root_path, alert: "Please log in to view matches."
    end
  end
end
