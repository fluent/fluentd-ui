class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    return unless session[:remember_token]
    @current_user ||= User.find_by(remember_token: session[:remember_token])
  end

  def login_require
    !!current_user
  end
end
