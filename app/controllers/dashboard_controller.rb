class DashboardController < ApplicationController
  before_action :set_mock_current_user

  def index
    @query = params[:q].to_s.strip
    @skill_requests = SkillExchangeRequest.includes(:user)
                                         .where(status: :open)
                                         .where("created_at > ?", 180.days.ago) # max expiration filter
                                         .order(created_at: :desc)
    
    # Filter out expired requests
    @skill_requests = @skill_requests.reject(&:expired?)
    
    if @query.present?
      q = "%#{@query.downcase}%"
      @skill_requests = @skill_requests.select do |r|
        r.teach_skill.downcase.include?(q.gsub("%", "")) ||
        r.learn_skill.downcase.include?(q.gsub("%", "")) ||
        r.user.name.downcase.include?(q.gsub("%", "")) ||
        r.modality.downcase.include?(q.gsub("%", ""))
      end
    end
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def set_mock_current_user
    @current_user ||= User.first_or_create!(
      email: "mock@example.com",
      name: "Mock User"
    )
  end

  def current_user
    @current_user
  end
  helper_method :current_user
end

