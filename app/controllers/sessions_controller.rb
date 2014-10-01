class SessionsController < ApplicationController
  layout "sign_in"
  skip_before_action :login_required, only: [:new, :create]
  before_action :set_user

  def create
    unless @user.authenticate(session_params[:password])
      flash.now[:notice] = I18n.t("messages.login_failed")
      return render :new
    end
    sign_in @user
    if session_params[:password] == Settings.default_password
      flash[:warning] = t('terms.changeme_password')
    end
    redirect_to root_path
  end

  def destroy
    session.delete :user_name
    session.delete :password
    redirect_to new_sessions_path
  end

  private

  def set_user
    @user = User.new(name: (params[:session] || {})[:name])
  end

  def session_params
    params.require(:session).permit(:name, :password)
  end

  def sign_in(user)
    # NOTE: Cookie will encrypt by Rails, but store raw password into session is a bad practice.
    #       If we use some DB in the future, change this to store token with expire limitation (not password).
    #
    #       Currently, only store to session if default password is used.
    # TODO: How to keep a login session to be decide
    session[:user_name] = user.name
    session[:password]  = session_params[:password]
  end
end
