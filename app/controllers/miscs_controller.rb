class MiscsController < ApplicationController
  def information
    @env = ENV
    @plugins = Plugin.installed
  end
end
