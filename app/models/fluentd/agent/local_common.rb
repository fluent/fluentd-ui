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
        File.open(config_file, "w") do |f|
          f.write content
        end
      end

      def config_append(content)
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

      private

      def pid
        return unless File.exists?(pid_file)
        File.read(pid_file).to_i rescue nil
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
    end
  end
end
