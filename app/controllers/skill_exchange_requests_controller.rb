# app/controllers/skill_exchange_requests_controller.rb
class SkillExchangeRequestsController < ApplicationController

    # before_action :authenticate_user!
    before_action :set_mock_current_user
    before_action :set_skill_exchange_request, only: [:show]
  
    def new
      @skill_exchange_request = SkillExchangeRequest.new
    end
  
    def create
      @skill_exchange_request = current_user.skill_exchange_requests.new(ser_params)
      if @skill_exchange_request.save
        redirect_to @skill_exchange_request, notice: "Your exchange request was posted!"
      else
        flash.now[:alert] = @skill_exchange_request.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end
  
    def show; end
  
    private
  
    # mock user for now
    def set_mock_current_user
      @current_user ||= ::User.first_or_create!(
        email: "mock@example.com",
        name: "Mock User"
      )
    end
  
    def current_user
      @current_user
    end
    helper_method :current_user
  
    def set_skill_exchange_request
      @skill_exchange_request = current_user.skill_exchange_requests.find(params[:id])
    end
  
    def ser_params
        params.require(:skill_exchange_request).permit(
          :teach_skill, :teach_level, :learn_skill, :learn_level,
          :offer_hours, :modality, :notes,
          :expires_after_days, :learning_goal,
          availability_days: []
        )
      end
  end
  