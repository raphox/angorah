class LoginController < ApplicationController
  def sign_in
    user = User.find(params[:user_id])

    session[:session_user_id] = user.id.to_s

    redirect_to root_path
  end
end
