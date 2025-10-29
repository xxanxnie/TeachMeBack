class DashboardController < ApplicationController
  before_action :require_login

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
        r.user.try(:full_name).to_s.downcase.include?(q.gsub("%", "")) ||
        r.modality.downcase.include?(q.gsub("%", ""))
      end
    end
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def require_login
    unless current_user
      redirect_to root_path, alert: "Please log in to access explore."
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user
end
