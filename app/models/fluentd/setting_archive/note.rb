class Fluentd
  module SettingArchive
    class Note
      include Archivable

      FILE_EXTENSION = ".note".freeze

      def self.find_by_file_id(backup_dir, file_id)
        new(file_path_of(backup_dir, file_id))
      end

      def self.create(file_path)
        FileUtils.touch(file_path)
        new(file_path)
      end

      def initialize(file_path)
        @file_path = file_path
      end

      def update!(content)
        File.open(@file_path, "w") do |f|
          f.write content
        end
      end
    end
  end
end
