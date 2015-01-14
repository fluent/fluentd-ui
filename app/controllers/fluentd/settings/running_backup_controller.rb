class Fluentd::Settings::RunningBackupController < ApplicationController
  include SettingHistoryConcern

  private

  def find_backup_file
    @backup_file = Fluentd::SettingArchive::BackupFile.new(@fluentd.agent.running_config_backup_file)
  end

  def after_dryrun_redirect(flash)
    redirect_to daemon_setting_running_backup_path, flash: flash
  end
end
