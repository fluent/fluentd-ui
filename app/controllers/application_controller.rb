class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :login_required

  def current_user
    return unless session[:remember_token]
    @current_user ||= LoginToken.active.find_by(token_id: session[:remember_token]).try(:user)
  end

  def login_required
    return true if current_user
    redirect_to new_sessions_path
  end

  private

  def find_fluentd
    @fluentd = Fluentd.find(params[:fluentd_id])
  end
end
