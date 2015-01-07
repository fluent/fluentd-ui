class Fluentd
  module SettingArchive
    class BackupFile
      include Archivable
      attr_reader :note

      FILE_EXTENSION = ".conf".freeze

      def self.find_by_file_id(backup_dir, file_id)
        note = Note.find_by_file_id(backup_dir, file_id) rescue nil
        new(file_path_of(backup_dir, file_id), note)
      end

      def initialize(file_path, note = nil)
        @file_path = file_path
        @note = note || Note.create(file_path.sub(/#{Regexp.escape(FILE_EXTENSION)}\z/, Note::FILE_EXTENSION))
      end
    end
  end
end
