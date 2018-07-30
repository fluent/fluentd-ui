require_relative "./stub_daemon"

module ConfigHistories
  module DaemonHaveSomeConfigHistories
    extend ActiveSupport::Concern
    include ::StubDaemon

    included do
      def daemon
        @daemon ||= stub_daemon
      end

      setup do
        config_contents = <<-CONFIG.strip_heredoc
          <source>
            @type forward
            port 24224
          </source>
        CONFIG
        new_config = <<-CONFIG
          <source>
            @type http
            port 8899
          </source>
        CONFIG

        three_hours_ago = Time.zone.now - 3.hours
        Timecop.freeze(three_hours_ago)
        FileUtils.rm_rf(daemon.agent.config_backup_dir)

        7.times do |i|
          backup_time = three_hours_ago - (i+1).hours
          FileUtils.touch(File.join(daemon.agent.config_backup_dir, "#{backup_time.strftime("%Y%m%d_%H%M%S")}.conf"))
        end

        Timecop.freeze(three_hours_ago + 1.hours)
        daemon.agent.config_write(config_contents)

        Timecop.freeze(three_hours_ago + 2.hours)
        daemon.agent.config_write(new_config)

        Timecop.freeze(three_hours_ago + 3.hours)
      end

      teardown do
        FileUtils.rm_rf(daemon.agent.config_backup_dir)
        Timecop.return
      end
    end
  end

  module DaemonHadBeenStartedOnce
    extend ActiveSupport::Concern

    included do
      setup do
        @backup_content = "Running backup file content"
        File.open(daemon.agent.running_config_backup_file, "w") do |file|
          file.write(@backup_content)
        end
      end

      teardown do
        FileUtils.rm_rf(daemon.agent.config_backup_dir)
      end
    end
  end
end
