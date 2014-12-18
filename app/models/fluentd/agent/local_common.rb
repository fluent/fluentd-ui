class Fluentd
  class Agent
    module LocalCommon
      def running?
        begin
          pid && Process.kill(0, pid)
        rescue Errno::ESRCH
          File.unlink(pid_file) # no needed any more
          false
        end
      end

      def log
        return "" unless File.exists?(log_file)
        File.read(log_file) # TODO: large log file
      end

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

      def log_tail(limit = nil)
        return [] unless File.exists?(log_file)

        limit = limit.to_i rescue 0
        limit = limit.zero? ? Settings.default_log_tail_count : limit
        io = File.open(log_file)
        buf = []
        reader = ::FileReverseReader.new(io)
        reader.each_line do |line|
          buf << line
          break if buf.length >= limit
        end
        buf
      end

      def configuration
        if File.exists? config_file
          ::Fluentd::Agent::Configuration.new(config_file)
        end
      end

      def pid
        return unless File.exists?(pid_file)
        return if File.zero?(pid_file)
        File.read(pid_file).to_i rescue nil
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

      private

      def backup_config
        return unless File.exists? config_file

        FileUtils.cp config_file, File.join(config_backup_dir, "#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.conf")

        remove_over_backup_files
      end

      def remove_over_backup_files
        over_file_count = backup_files.size - ::Settings.max_backup_files_count

        return if over_file_count <= 0

        backup_files_in_old_order.first(over_file_count).each do |file|
          next unless File.exist? file
          FileUtils.rm(file)
        end
      end

      def logged_errors(&block)
        return [] unless File.exist?(log_file)
        buf = []
        io = File.open(log_file)
        reader = ::FileReverseReader.new(io)
        reader.each_line do |line|
          unless line["error"]
            if buf.present?
              # NOTE: if a following log is given
              #         2014-06-30 11:24:08 +0900 [error]: unexpected error error_class=Errno::EADDRINUSE error=#<Errno::EADDRINUSE: Address already in use - bind(2) for 0.0.0.0:24220>
              #         2014-06-30 11:24:08 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.2/lib/ruby/2.1.0/socket.rb:206:in `bind'
              #         2014-06-30 11:24:08 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.2/lib/ruby/2.1.0/socket.rb:206:in `listen'
              #         2014-06-30 11:24:08 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.2/lib/ruby/2.1.0/socket.rb:461:in `block in tcp_server_sockets'
              #       the first line become a "subject", trailing lines are "notes"
              #       {
              #         subject: "2014-06-30 11:24:08 +0900 [error]: unexpected error error_class=Errno::EADDRINUSE error=#<Errno::EADDRINUSE: Address already in use - bind(2) for 0.0.0.0:24220>",
              #         notes: [
              #           2014-06-30 11:24:08 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.2/lib/ruby/2.1.0/socket.rb:206:in `bind'
              #           2014-06-30 11:24:08 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.2/lib/ruby/2.1.0/socket.rb:206:in `listen'
              #           2014-06-30 11:24:08 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.2/lib/ruby/2.1.0/socket.rb:461:in `block in tcp_server_sockets'
              #         ]
              #       }
              subject, *notes = *buf.reverse
              block.call({
                subject: subject,
                notes: notes,
              })
            end
            buf = []
            next
          end
          buf << line
        end
      ensure
        io && io.close
      end

      def detached_command(cmd)
        Bundler.with_clean_env do
          pid = spawn(cmd)
          Process.detach(pid)
        end
        sleep 1 # NOTE/FIXME: too early return will be caused incorrect status report, "sleep 1" is a adhoc hack
      end
    end
  end
end
