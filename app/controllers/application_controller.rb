class ApplicationController < ActionController::Base
  before_action :set_session_user_id

  def set_session_user_id
    if session[:session_user_id].present?
      @current_user = User.find(session[:session_user_id]) rescue nil
    end

    @current_user = User.first if @current_user.nil?

    session[:session_user_id] = @current_user.id.to_s
  end
end
