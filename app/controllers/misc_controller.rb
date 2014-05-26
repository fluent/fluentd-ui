require "fluent/version"

class MiscController < ApplicationController
  def show
    redirect_to misc_information_path
  end

  def information
    @env = ENV
    @plugins = Plugin.installed
  end
end
