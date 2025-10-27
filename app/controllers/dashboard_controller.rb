class DashboardController < ApplicationController
  before_action :require_login

  def index
    @loading = true
    # Later: load dashboard data here
  end

  private

  def require_login
    unless current_user
      redirect_to login_path, alert: "Please log in to access your dashboard."
    end
  end
end
