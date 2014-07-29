class Fluentd::SettingsController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def show
    @config = @fluentd.agent.config
  end

  def edit
    @config = @fluentd.agent.config
  end

  def  update
    @fluentd.agent.config_write params[:config]
    @fluentd.agent.restart if @fluentd.agent.running?
    redirect_to daemon_setting_path(@fluentd)
  end
end
