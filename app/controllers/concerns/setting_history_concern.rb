module SettingHistoryConcern
  extend ActiveSupport::Concern

  included do
    before_action :login_required
    before_action :find_fluentd
    before_action :find_backup_file, only: [:show, :reuse, :configtest]
  end

  def show
    current = @fluentd.agent.config
    target = @backup_file.content
    if target
      @sdiff = Diff::LCS.sdiff(current.split("\n").map(&:rstrip), target.split("\n").map(&:rstrip))
      @changed = @sdiff.any? { |context_change| context_change.changed? }
    end
  end

  def reuse
    @fluentd.agent.config_write @backup_file.content
    redirect_to daemon_setting_path, flash: { success: t('messages.config_successfully_copied',  brand: fluentd_ui_brand) }
  end

  def configtest
    @fluentd.config_file = @backup_file.file_path
    if @fluentd.agent.dryrun
      flash = { success: t('messages.dryrun_is_passed') }
    else
      flash = { danger: @fluentd.agent.log.tail(1).first }
    end
    redirect_to :back, flash: flash
  end

end
