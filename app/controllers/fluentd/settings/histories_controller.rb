class Fluentd::Settings::HistoriesController < ApplicationController
  include SettingHistoryConcern

  def index
    @backup_files = @fluentd.agent.backup_files_in_new_order.map do |file_path|
      Fluentd::SettingArchive::BackupFile.new(file_path)
    end
  end

  private

  def find_backup_file
    #Do not use BackupFile.new(params[:id]) because params[:id] can be any path.
    @backup_file = Fluentd::SettingArchive::BackupFile.find_by_file_id(@fluentd.agent.config_backup_dir, params[:id])
  end

  def after_dryrun_redirect(flash)
    redirect_to daemon_setting_history_path(params[:id]), flash: flash
  end
end
