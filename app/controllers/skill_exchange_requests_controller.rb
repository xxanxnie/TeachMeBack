# app/controllers/skill_exchange_requests_controller.rb
class SkillExchangeRequestsController < ApplicationController

    before_action :require_login, only: [:new, :create, :show]
    # before_action :authenticate_user!
    before_action :set_skill_exchange_request, only: [:show]
   
    def index
      @requests = SkillExchangeRequest.all
    end

    def new
      @loading = true
      @skill_exchange_request = SkillExchangeRequest.new
    end
  
    def create
      @skill_exchange_request = current_user.skill_exchange_requests.new(ser_params)
      if @skill_exchange_request.save
        redirect_to explore_path, notice: "Your skill exchange request was posted successfully!"
      else
        @loading = true
        flash.now[:alert] = @skill_exchange_request.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end
  
    def show; end
  
    private
  
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
  
