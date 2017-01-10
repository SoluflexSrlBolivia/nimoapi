class AccountActivationsController < ApplicationController

  api! "Activacion de una cuenta, que posteriormente recibio en su mail"
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = t(:account_active)
      render 'user'
    else
      flash[:danger] = t(:invalid_activation_link)
      redirect_to root_url
    end
  end
end
