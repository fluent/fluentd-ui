require "fluent/version"

class MiscController < ApplicationController
  after_action :update!, only: [:update_fluentd_ui]

  def show
    redirect_to misc_information_path
  end

  def information
    @env = ENV
    @plugins = Plugin.installed
  end

  def update_fluentd_ui
    @current_pid = $$
    render "update_fluentd_ui", layout: "sign_in"
  end

  def upgrading_status
    if FluentdUiRestart::LOCK.present?
      return render text: "updating"
    end

    if $$.to_s == params[:old_pid]
      # restarting fluentd-ui is finished, but PID doesn't changed.
      # maybe error occured at FluentdUiRestart#perform
      render text: "failed"
    else
      render text: "finished"
    end
  end

  private

  def update!
    FluentdUiRestart.new.async.perform
  end
end
