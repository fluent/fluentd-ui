class Fluentd::Settings::HistoriesController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :find_backup_file, only: [:show, :reuse]

  def index
    @backup_files = @fluentd.agent.backup_files_in_new_order.map do |file_path|
      Fluentd::Setting::BackupFile.new(file_path: file_path)
    end
  end

  def show
  end

  def reuse
    @fluentd.agent.config_write @backup_file.content
    redirect_to daemon_setting_path, flash: { success: t('messages.config_successfully_copied',  brand: fluentd_ui_brand) }
  end

  private

  def find_backup_file
    #Do not use BackupFile.new(params[:id]) because params[:id] can be any path.
    @backup_file = Fluentd::Setting::BackupFile.find_by_file_id(
      {
        backup_dir: @fluentd.agent.config_backup_dir,
        file_id: params[:id]
      }
    )
  end
end
