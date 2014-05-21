class MiscsController < ApplicationController
  def show
    redirect_to information_misc_path
  end

  def information
    @env = ENV
    @plugins = Plugin.installed
  end
end
