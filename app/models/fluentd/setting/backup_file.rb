class Fluentd
  module Setting
    class BackupFile
      attr_accessor :file_path

      def self.find_by_file_id(backup_dir, file_id)
        file_path = Pathname.new(backup_dir).join("#{file_id}.conf")
        raise "No suce file #{file_path}" unless File.exist?(file_path)

        new(file_path)
      end

      def initialize(file_path)
        @file_path = file_path
      end

      def file_id
        @file_id ||= with_file { name.gsub(/.conf\Z/,'') }
      end

      def name
        @name ||= with_file { File.basename(file_path) }
      end

      def content
        @content ||= with_file { File.open(file_path, "r") { |f| f.read } }
      end

      def ctime
        with_file { File.ctime(file_path) }
      end

      private

      def with_file
        return nil unless file_path && File.exist?(file_path)
        yield
      end
    end
  end
end
