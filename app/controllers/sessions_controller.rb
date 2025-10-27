class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    # Minimal (not secure) password check for MVP
    if user && user.password.to_s == params[:password].to_s
      session[:user_id] = user.id
      flash[:notice] = "Welcome back"
      redirect_to "/dashboard"
    else
      flash.now[:notice] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    flash[:notice] = "Signed out"
    redirect_to root_path
  end
end

