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
          note_file_attached_backup = file.sub(/#{Regexp.escape(File.extname(file))}\z/, ::Fluentd::SettingArchive::Note::FILE_EXTENSION)
          FileUtils.rm(note_file_attached_backup) if File.exist? note_file_attached_backup
          FileUtils.rm(file) if File.exist? file
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
              split_error_lines_to_error_units(buf.reverse).each do |error_unit|
                block.call({
                  subject: error_unit[:subject],
                  notes: error_unit[:notes],
                })
              end
            end

            buf = []
            next
          end
          buf << line
        end
      ensure
        io && io.close
      end

      def split_error_lines_to_error_units(buf)
        # NOTE: if a following log is given
        #
        #2014-05-27 10:54:37 +0900 [error]: unexpected error error_class=Errno::EADDRINUSE error=#<Errno::#EADDRINUSE: Address already in use - bind(2) for "0.0.0.0" port 24224>
        #2014-05-27 10:55:40 +0900 [error]: unexpected error error_class=Errno::EADDRINUSE error=#<Errno::#EADDRINUSE: Address already in use - bind(2) for "0.0.0.0" port 24224>
        #  2014-05-27 10:55:40 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.0/lib/ruby/gems/2.1.0/gems/cool.io-1.2.4/lib/cool.io/server.rb:57:in `initialize'
        #  2014-05-27 10:55:40 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.0/lib/ruby/gems/2.1.0/gems/cool.io-1.2.4/lib/cool.io/server.rb:57:in `new'
        #
        #the first line and second line must be each "error_unit". and after third lines lines are "notes" of second error unit of .
        # [
        #   { subject: "2014-05-27 10:54:37 +0900 [error]: unexpected error error_class=Errno::EADDRINUSE error=#<Errno::#EADDRINUSE: Address already in use - bind(2) for "0.0.0.0" port 24224>          ",
        #     notes: [] },
        #   { subject: "2014-05-27 10:55:40 +0900 [error]: unexpected error error_class=Errno::EADDRINUSE error=#<Errno::#EADDRINUSE: Address already in use - bind(2) for "0.0.0.0" port 24224>          ",
        #     notes: [
        #       "2014-05-27 10:55:40 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.0/lib/ruby/gems/2.1.0/gems/cool.io-1.2.4/lib/cool.io/server.rb:57:in `initialize'",
        #       "2014-05-27 10:55:40 +0900 [error]: /Users/uu59/.rbenv/versions/2.1.0/lib/ruby/gems/2.1.0/gems/cool.io-1.2.4/lib/cool.io/server.rb:57:in `new'"
        #     ]
        #   },
        # ]
        #
        return_array = []
        buf.each_with_index do |b, i|
          if b.match(/\A /)
            return_array[-1][:notes] << b
          else
            return_array << { subject: b, notes: [] }
          end
        end
        return return_array.reverse
      end

      def detached_command(cmd)
        thread = Bundler.with_clean_env do
          pid = spawn(cmd)
          Process.detach(pid)
        end
        thread.join
        thread.value.exitstatus.zero?
      end
    end
  end
end
