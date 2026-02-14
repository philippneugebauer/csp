class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[ new create ]

  def new
    redirect_to root_path if authenticated?
  end

  def create
    customer_success_manager = CustomerSuccessManager.active.find_by(email: params[:email].to_s.downcase.strip)

    if customer_success_manager&.authenticate(params[:password])
      session[:customer_success_manager_id] = customer_success_manager.id
      redirect_to root_path, notice: "Welcome back, #{customer_success_manager.first_name}."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:customer_success_manager_id)
    redirect_to login_path, notice: "Logged out successfully."
  end
end
