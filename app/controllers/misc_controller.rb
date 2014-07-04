require "fluent/version"

class MiscController < ApplicationController
  def show
    redirect_to misc_information_path
  end

  def information
    @env = ENV
    @plugins = Plugin.installed
  end

  def update_fluentd_ui
    # TODO: Plugin.new(gem_name: "fluentd-ui").install
    FluentdUiRestart.new.async.perform
    render "update_fluentd_ui", layout: "sign_in"
  end
end
