require "fluent/config/basic_parser"
require 'fluent/config/parser'

class FluentdController < ApplicationController
  include FluentdConfig

  before_action :find_fluentd, only: [:show, :edit, :update, :destroy, :log, :raw_log, :errors]
  before_action :check_fluentd_exists, only: [:edit, :log, :raw_log, :errors]

  def dashboard
    path = File.expand_path(Fluentd.instance.config_file)
    File.open(path) { |io|
      @root_conf = Fluent::Config::Parser.parse(io, File.basename(path), File.dirname(path))
    }

    raw_sources = []
    raw_matches = []
    @root_conf.elements.each do |c|
      raw_sources << c if c.name == 'source'
      raw_matches << c if c.name == 'match'
    end
    
    @sources = {}
    raw_sources.each do |s|
      source = SourceElement.new
      next unless s["tag"]
      @sources[s["tag"]] ||= []

      source.type = s["type"]
      source.tag = s["tag"]
      source.describe = s["describe"]
      source.interval = s["interval"]
      @sources[s["tag"]] << source
    end

    @matches = []
    raw_matches.each do |m|
        match = MatchElement.new
        match.type = m["type"]
        match.describe = m["describe"]
        match.stores = []
        match.sources = @sources[m.arg] || []
        m.elements.each do |e|
          next unless e.name == "store"
          match.stores << e["type"]
        end
        @matches << match
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
