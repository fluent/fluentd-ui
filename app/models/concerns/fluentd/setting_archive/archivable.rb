class Fluentd
  module SettingArchive
    module Archivable
      extend ActiveSupport::Concern
      attr_accessor :file_path

      module ClassMethods
        private

        def file_path_of(dir, id)
          file_path = Pathname.new(dir).join("#{id}#{self::FILE_EXTENSION}")
          raise "No such a file #{file_path}" unless File.exist?(file_path)
          file_path
        end
      end

      def file_id
        @file_id ||= with_file { name.gsub(/#{self.class::FILE_EXTENSION}\Z/,'') }
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
