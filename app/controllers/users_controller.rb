class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to dashboard_path, notice: "Welcome, #{@user.name}!"
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # profile edit placeholder
  end

  def update
    # profile update placeholder
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
