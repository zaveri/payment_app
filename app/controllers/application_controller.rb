class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def logged_in?
    if(current_user == nil)
      redirect_to '/sign_in'
    end
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user
   
end
