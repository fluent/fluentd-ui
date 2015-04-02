require "fluent/config/v1_parser"

class Fluentd::SettingsController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :set_config, only: [:show, :edit, :update]

  def show
    @backup_files = @fluentd.agent.backup_files_in_new_order.first(Settings.histories_count_in_preview).map do |file_path|
      Fluentd::SettingArchive::BackupFile.new(file_path)
    end

    @running_backedup_file = Fluentd::SettingArchive::BackupFile.new(@fluentd.agent.running_config_backup_file)
  end

  def edit
  end

  def  update
    if params[:dryrun]
      handle_dryrun
    else
      handle_update
    end
  end

  def source_and_output
    # TODO: error handling if config file has invalid syntax
    # @config = Fluentd::Setting::Config.new(@fluentd.config_file)
  end

  private

  def set_config
    @config = @fluentd.agent.config
  end

  def handle_dryrun
    if dryrun(params[:config])
      begin
        parse_config(params[:config])
        flash.now[:success] = I18n.t('messages.dryrun_is_passed')
      rescue Fluent::ConfigParseError => e
        flash.now[:danger] = e.message
      end
    else
      flash.now[:danger] = @fluentd.agent.log.last_error_message
    end
    @config = params[:config]
    render "edit"
  end

  def handle_update
    parse_config(params[:config])
    update_config(params[:config])
    redirect_to daemon_setting_path(@fluentd)
  rescue Fluent::ConfigParseError => e
    @config = params[:config]
    flash.now[:danger] = e.message
    render "edit"
  end

  def dryrun(conf)
    tmpfile = Tempfile.open("fluentd-test-config")
    tmpfile.write params[:config]
    tmpfile.close
    @fluentd.agent.dryrun(tmpfile.path)
  end

  def parse_config(conf)
    # V1Parser.parse could raise exception
    Fluent::Config::V1Parser.parse(conf, @fluentd.config_file)
  end

  def update_config(conf)
    @fluentd.agent.config_write conf
    @fluentd.agent.restart if @fluentd.agent.running?
  end
end
