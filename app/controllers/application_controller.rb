class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: -> { Rails.env.test? }

  allow_browser versions: :modern

  stale_when_importmap_changes

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user.present?

    msg =
      case request.path
      when %r{\A/explore} then "Please log in to access explore."
      when %r{\A/profile} then "Please log in to access your profile."
      when %r{\A/skill_exchange_requests/new} then "Please log in to access this page."
      else "Please log in to access this page."
      end

    flash[:alert] = msg
    redirect_to login_path
  end
end
