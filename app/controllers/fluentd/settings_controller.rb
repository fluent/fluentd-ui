class Fluentd::SettingsController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def show
    @config = File.read(@fluentd.agent.config_file) # TODO
  end

  def edit
    @config = File.read(@fluentd.agent.config_file) # TODO
  end

  def  update
    File.open(@fluentd.agent.config_file, "w") do |f| # TODO: should update by agent class
      f.write params[:config]
    end
    @fluentd.agent.restart if @fluentd.agent.running?
    redirect_to fluentd_setting_path(@fluentd)
  end
end
