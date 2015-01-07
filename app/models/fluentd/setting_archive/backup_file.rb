class Fluentd
  module SettingArchive
    class BackupFile
      include Archivable

      FILE_EXTENSION = ".conf".freeze

      def self.find_by_file_id(backup_dir, file_id)
        new(file_path_of(backup_dir, file_id))
      end

      def initialize(file_path)
        @file_path = file_path
      end
    end
  end
end
