class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Welcome, #{@user.name}\nYour email has been verified as .edu"
      redirect_to login_path, notice: "Account created successfully. Please log in."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @loading = true
    @user = current_user
  end

  def update
    if current_user.update(user_params)
      redirect_to profile_path
    else
      @user = current_user
      flash.now[:alert] = current_user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :name, :email, :password, :bio, :location, :university)
  end

  def require_login
    unless current_user
      redirect_to root_path, alert: "Please log in to access your profile."
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user
end
