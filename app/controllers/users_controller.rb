class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: "Account created successfully. Please log in."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # profile edit placeholder
    @loading = true
    @user = current_user
  end

  def update
    # profile update placeholder
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
