require "fluent/config/basic_parser"
require 'fluent/config/parser'

class FluentdController < ApplicationController
  before_action :find_fluentd, only: [:show, :edit, :update, :destroy, :log, :raw_log, :errors]
  before_action :check_fluentd_exists, only: [:edit, :log, :raw_log, :errors]

  def dashboard
    path = File.expand_path(Fluentd.instance.config_file)
    File.open(path) { |io|
      @root_conf = Fluent::Config::Parser.parse(io, File.basename(path), File.dirname(path))
    }

    @main_config = path
    @sources = []
    @matches = []
    @root_conf.elements.each do |c|
      @sources << c if c.name == 'source'
      @matches << c if c.name == 'match'
    end
  end


  def show
  end

  def new
    @fluentd = Fluentd.new(variant: params[:variant] || "fluentd")
    @fluentd.load_settings_from_agent_default
  end

  def create
    @fluentd = Fluentd.new(fluentd_params)
    unless @fluentd.save
      return render :new
    end
    redirect_to daemon_path
  end

  def edit
  end

  def update
    # TODO: should restart if changed file path? or just do "dirty" flagged?
    @fluentd.update_attributes(fluentd_params)
    unless @fluentd.save
      return render :edit
    end
    redirect_to daemon_path
  end
  
  def destroy
    @fluentd.agent.stop if @fluentd.agent.running?
    @fluentd.destroy
    redirect_to root_path, flash: {success: t('messages.destroy_succeed_fluentd_setting', brand: fluentd_ui_brand)}
  end

  def log
  end

  def errors
    @error_duration_days = 5
    @errors = @fluentd.agent.errors_since(@error_duration_days.days.ago)
  end

  def raw_log
    send_data @fluentd.agent.log, type: "application/octet-stream", filename: File.basename(@fluentd.log_file)
  end

  private

  def fluentd_params
    params.require(:fluentd).permit(:log_file, :pid_file, :config_file, :variant, :api_endpoint)
  end

  def check_fluentd_exists
    unless fluentd_exists?
      redirect_to root_path
    end
  end
end
