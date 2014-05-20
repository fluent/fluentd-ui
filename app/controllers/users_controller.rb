class UsersController < ApplicationController
  before_action :login_required

  def index
    @users = User.all
  end
end
