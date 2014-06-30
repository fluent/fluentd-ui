class WelcomeController < ApplicationController
  def home
    redirect_to fluentd_path
  end
end
