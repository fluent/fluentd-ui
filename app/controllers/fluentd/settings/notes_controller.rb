class Fluentd::Settings::NotesController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :find_note, only: [:update]

  def update
    @note.update!(params[:note][:content])
    redirect_to daemon_setting_path, flash: { success: t('messages.note_updating_success') }
  end

  private

  def find_note
    @note = Fluentd::SettingArchive::Note.find_by_file_id(@fluentd.agent.config_backup_dir, params[:id])
  end
end
