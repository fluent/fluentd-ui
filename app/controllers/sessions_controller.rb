class SessionsController < ApplicationController
  layout "sign_in"

  def create
    user = User.find_by(name: session_params[:name]).try(:authenticate, session_params[:password])
    unless user
      flash.now[:notice] = I18n.t("error.login_failed")
      return render :new
    end
    sign_in user
    redirect_to root_path
  end

  def destroy
    current_user.update_attribute(:remember_token, nil)
    session.delete :remember_token
    redirect_to new_sessions_path
  end

  private

  def session_params
    params.require(:session).permit(:name, :password)
  end

  def sign_in(user)
    token = user.generate_remember_token
    session[:remember_token] = token
    user.update_attribute(:remember_token, token)
    user
  end
end
