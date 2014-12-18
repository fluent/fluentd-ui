class Fluentd::Settings::RunningBackupController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :find_backup_file, only: [:show, :reuse]

  def show
  end

  def reuse
    @fluentd.agent.config_write @backup_file.content
    redirect_to daemon_setting_path, flash: { success: t('messages.config_successfully_copied',  brand: fluentd_ui_brand) }
  end

  private

  def find_backup_file
    @backup_file = Fluentd::Setting::BackupFile.new(@fluentd.agent.running_config_backup_file)
  end
end
