class MessagesController < ApplicationController
  before_action :ensure_logged_in

  def index
    if current_user.respond_to?(:thread_partners)
      @partners = current_user.thread_partners
    else
      ids = Message.where("sender_id = :id OR recipient_id = :id", id: current_user.id)
                   .pluck(:sender_id, :recipient_id)
                   .flatten
                   .uniq - [current_user.id]
      @partners = User.where(id: ids)
    end
  end

  def thread
    partner_id = params[:with] || params[:user_id]
    raise ActiveRecord::RecordNotFound, "Missing conversation partner" if partner_id.blank?

    @partner  = User.find(partner_id)
    @messages = Message.between(current_user.id, @partner.id).order(:created_at)
    @messages.where(recipient_id: current_user.id, read_at: nil).update_all(read_at: Time.current)
    @message  = Message.new(recipient_id: @partner.id)
  end

  def create
    @message = Message.new(message_params.merge(sender_id: current_user.id))

    if @message.save
      redirect_to message_thread_path(with: @message.recipient_id), notice: "Sent."
    else
      @partner  = User.find(message_params[:recipient_id])
      @messages = Message.between(current_user.id, @partner.id).order(:created_at)
      flash.now[:alert] = @message.errors.full_messages.to_sentence
      render :thread, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:recipient_id, :body)
  end

  def ensure_logged_in
    redirect_to login_path, alert: "Please sign in to continue" unless current_user
  end
end

