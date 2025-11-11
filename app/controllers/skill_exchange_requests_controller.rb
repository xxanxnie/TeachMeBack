# app/controllers/skill_exchange_requests_controller.rb
class SkillExchangeRequestsController < ApplicationController

    before_action :require_login, only: [:new, :create, :show]
    before_action :set_skill_exchange_request, only: [:show]
   
    def index
      @requests = SkillExchangeRequest.all
    end

    def new
      @loading = true
      @skill_exchange_request = SkillExchangeRequest.new
    end
  
    def create
      @skill_exchange_request = current_user.skill_exchange_requests.build(skill_exchange_request_params)

      if @skill_exchange_request.save
        redirect_to explore_path, notice: "Posted."
      else
        render :new
      end
    end
  
    def show; end
  
    private
  
    def set_skill_exchange_request
      @skill_exchange_request = current_user.skill_exchange_requests.find(params[:id])
    end
  
    def skill_exchange_request_params
      params.require(:skill_exchange_request).permit(
        :teach_skill, :learn_skill,
        :teach_level, :learn_level,
        :offer_hours, :modality,
        :expires_after_days, :learning_goal,
        :teach_category, :learn_category,
        availability_days: []
      )
    end
  end

