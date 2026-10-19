class SessionsController < ApplicationController
  def new; end

  def create
    admin = AdminUser.find_by(email: params[:email])
    if admin&.authenticate(params[:password])
      session[:admin_id] = admin.id
      redirect_to root_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end
end
