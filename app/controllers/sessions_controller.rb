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
    LoginToken.where(token_id: session[:remember_token]).delete_all
    LoginToken.inactive.delete_all # GC
    session.delete :remember_token
    redirect_to new_sessions_path
  end

  private

  def session_params
    params.require(:session).permit(:name, :password)
  end

  def sign_in(user)
    token = user.login_tokens.create(expired_at: 10.hours.from_now) # TODO: decide lifetime
    session[:remember_token] = token.token_id
    user
  end
end
