class UsersController < ApplicationController
  before_action :login_required
  before_action :find_user

  def show
  end

  def update
    unless @user.authenticate(user_params[:current_password])
      @user.errors.add(:current_password, :wrong_password)
      return render :show
    end
    unless @user.update_attributes(user_params)
      return render :show
    end
    redirect_to misc_user_path
  end

  private

  def find_user
    @user = User.first # user is only "admin"
  end

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
