class WelcomeController < ApplicationController
  def home
    redirect_to daemon_path
  end
end
