class MatchController < ApplicationController
  before_action :require_login

  def index
    @loading = true
    @matches = current_user.matches.includes(:user1, :user2)
  end

  private

  def require_login
    unless current_user
      redirect_to root_path, alert: "Please log in to view matches."
    end
  end
end
