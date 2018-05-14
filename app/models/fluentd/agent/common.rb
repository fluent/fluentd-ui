# pidfile
#   td-agent: /var/run/td-agent/td-agent.pid
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L18
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/deb/td-agent#L24
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/rpm/td-agent#L24
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/td-agent/logrotate.d/td-agent.logrotate#L10
#   fluentd:  nothing (or --daemon PIDFILE)
#
# logfile
#   td-agent: /var/log/td-agent/td-agent.log
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L21
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/deb/td-agent#L23
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/rpm/td-agent#L23
#   fluentd: stdout (or --log LOGFILE)
#
# config file
#   td-agent: /etc/td-agent/td-agent.conf
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L14
#   fluentd: /etc/fluent/fluent.conf (created by fluentd -s)

class Fluentd
  class Agent
    module Common
      attr_reader :extra_options

      def self.included(base)
        base.include(Fluentd::Agent::ProcessOperation)
      end

      # define these methods on each Agent class
      %w(start stop restart version).each do |method|
        define_method(method) do
          raise NotImplementedError, "'#{method}' method is required to be defined"
        end
      end

      def initialize(options = {})
        @extra_options = options
      end

      def pid_file
        extra_options[:pid_file] || self.class.default_options[:pid_file]
      end

      def log_file
        extra_options[:log_file] || self.class.default_options[:log_file]
      end

      def log
        @log ||= FluentdLog.new(log_file)
      end

      def config_file
        extra_options[:config_file] || self.class.default_options[:config_file]
      end

      # -- config
      def config
        File.read(config_file)
      end

      def config_write(content)
        backup_config
        File.open(config_file, "w") do |f|
          f.write content
        end
      end

      def config_append(content)
        backup_config
        File.open(config_file, "a") do |f|
          f.write "\n"
          f.write content
        end
      end

      def configuration
        if File.exists? config_file
          ::Fluentd::Agent::Configuration.new(config_file)
        end
      end

      # -- backup methods
      def config_backup_dir
        dir = File.join(FluentdUI.data_dir, "#{Rails.env}_confg_backups")
        FileUtils.mkdir_p(dir)
        dir
      end

      def backup_files
        Dir.glob(File.join("#{config_backup_dir}", "*.conf"))
      end

      def backup_files_in_old_order
        backup_files.sort
      end

      def backup_files_in_new_order
        backup_files_in_old_order.reverse
      end

      def running_config_backup_dir
        dir = File.join(FluentdUI.data_dir, "#{Rails.env}_running_confg_backup")
        FileUtils.mkdir_p(dir)
        dir
      end

      def running_config_backup_file
        File.join(running_config_backup_dir, "running.conf")
      end

      # -------------- private --------------
      private

      def backup_running_config
        #back up config file only when start success
        return unless yield

        return unless File.exists? config_file

        FileUtils.cp config_file, running_config_backup_file

        true
      end

      def backup_config
        return unless File.exists? config_file

        FileUtils.cp config_file, File.join(config_backup_dir, "#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.conf")

        remove_over_backup_files
      end

      def remove_over_backup_files
        over_file_count = backup_files.size - ::Settings.max_backup_files_count

        return if over_file_count <= 0

        backup_files_in_old_order.first(over_file_count).each do |file|
          note_file_attached_backup = file.sub(/#{Regexp.escape(File.extname(file))}\z/, ::Fluentd::SettingArchive::Note::FILE_EXTENSION)
          FileUtils.rm(note_file_attached_backup) if File.exist? note_file_attached_backup
          FileUtils.rm(file) if File.exist? file
        end
      end
    end
  end
end
