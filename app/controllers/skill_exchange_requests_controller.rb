# app/controllers/skill_exchange_requests_controller.rb
class SkillExchangeRequestsController < ApplicationController
    before_action :require_login, only: [:index, :new, :create, :show, :update, :express_interest]
    before_action :set_skill_exchange_request, only: [:show, :update]
   
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
        render :new, status: :unprocessable_content
      end
    end
  
    # Express interest in a specific skill exchange request.
    # This creates a UserSkillRequest between the current user and the
    # owner of the request (if one does not already exist) and, if there
    # is a reciprocal request, results in a Match which then links into
    # the messaging thread.
    def express_interest
      @skill_exchange_request = SkillExchangeRequest.find(params[:id])
      receiver = @skill_exchange_request.user

      if receiver == current_user
        redirect_back(fallback_location: explore_path, alert: "You can't express interest in your own request.")
        return
      end

      existing_request = UserSkillRequest.find_by(
        requester_id: current_user.id,
        receiver_id: receiver.id
      )

      if existing_request
        redirect_back(fallback_location: explore_path, alert: "You have already sent a request to this user.")
        return
      end

      user_skill_request = UserSkillRequest.new(
        requester: current_user,
        receiver: receiver,
        # Use the other user's teach_skill as the skill you're interested in
        skill: @skill_exchange_request.teach_skill
      )

      if user_skill_request.save
        # After save, the UserSkillRequest callback may have created a Match.
        user_ids = [current_user.id, receiver.id].sort
        match = Match.find_by(user1_id: user_ids[0], user2_id: user_ids[1])

        if match
          # This express-interest came from this specific post; mark it as matched
          # so only this posting is considered taken while others stay open.
          @skill_exchange_request.update(status: :matched) if @skill_exchange_request.status_open?

          # Directly into the message thread on mutual match
          redirect_to message_thread_path(with: receiver.id),
                      notice: "Congrats, it's a match! You and #{receiver.full_name} expressed interest in each other. Start chatting!"
        else
          redirect_back(fallback_location: explore_path,
                        notice: "Interest sent to #{receiver.full_name}. You'll be notified when they reciprocate.")
        end
      else
        redirect_back(fallback_location: explore_path,
                      alert: user_skill_request.errors.full_messages.to_sentence)
      end
    end

    # Allow the owner to update their request, e.g., to mark it as completed/closed
    def update
      unless @skill_exchange_request.user == current_user
        head :forbidden
        return
      end

      if @skill_exchange_request.update(skill_exchange_request_update_params)
        redirect_back(fallback_location: profile_path,
                      notice: "Skill exchange request updated.")
      else
        redirect_back(fallback_location: profile_path,
                      alert: @skill_exchange_request.errors.full_messages.to_sentence)
      end
    end
  
    def show; end

    private
  
    def set_skill_exchange_request
      @skill_exchange_request = current_user.skill_exchange_requests.find(params[:id])
    end

    def skill_exchange_request_update_params
      # For now, only allow status changes from the profile/history UI.
      params.require(:skill_exchange_request).permit(:status)
    end
  
    def skill_exchange_request_params
      params.require(:skill_exchange_request).permit(
        :teach_skill, :learn_skill,
        :teach_level, :learn_level,
        :offer_hours, :modality,
        :expires_after_days, :learning_goal,
        :notes,
        :teach_category, :learn_category,
        availability_days: []
      )
    end
  end
