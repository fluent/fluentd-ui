class UsersController < ApplicationController
  before_action :find_user

  def show
  end

  def update
    unless @user.update_attributes(user_params)
      return render :show
    end
    session[:password] = user_params[:password]
    redirect_to user_path, notice: I18n.t("messages.password_successfully_updated")
  end

  private

  def find_user
    @user = User.new(name: session[:user_name])
  end

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
