class UserSkillRequestsController < ApplicationController
  before_action :require_login

  def create
    @receiver = User.find(params[:receiver_id])
    @skill_exchange_request = SkillExchangeRequest.find_by(id: params[:skill_exchange_request_id])
    @skill = params[:skill].presence || @skill_exchange_request&.teach_skill || "general"

    existing_request = UserSkillRequest.find_by(
      requester_id: current_user.id,
      receiver_id: @receiver.id,
      skill_exchange_request_id: @skill_exchange_request&.id,
      skill: @skill
    )

    if existing_request
      redirect_back(fallback_location: explore_path, alert: "You have already sent a request for this posting.")
      return
    end

    @user_skill_request = UserSkillRequest.new(
      requester: current_user,
      receiver: @receiver,
      skill: @skill,
      skill_exchange_request: @skill_exchange_request
    )

    if @user_skill_request.save
      @user_skill_request.reload

      user_ids = [current_user.id, @receiver.id].sort
      match = Match.find_by(user1_id: user_ids[0], user2_id: user_ids[1])

      if match
        redirect_to message_thread_path(with: @receiver.id),
                    notice: "Congrats, it's a match! You and #{@receiver.full_name} expressed interest in each other. Start chatting!"
      else
        redirect_back(fallback_location: explore_path,
                      notice: "Request sent to #{@receiver.full_name}.")
      end
    else
      redirect_back(fallback_location: explore_path, alert: @user_skill_request.errors.full_messages.to_sentence)
    end
  end

  private

  def require_login
    unless current_user
      redirect_to root_path, alert: "Please log in to send requests."
    end
  end
end