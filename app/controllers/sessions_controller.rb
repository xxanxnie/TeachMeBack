class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to explore_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid email or password"
      if params[:auth_source] == "home"
        render "home/index", status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
