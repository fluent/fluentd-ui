class Fluentd
  class Agent
    module Log
      def log
        return "" unless File.exists?(log_file)
        File.read(log_file) # TODO: large log file
      end

      def errors_since(since = 1.day.ago)
        errors = []
        logged_errors do |error|
          break if Time.parse(error[:subject]) < since
          errors << error
        end
        errors
      end

      def recent_errors(limit = 3)
        errors = []
        logged_errors do |error|
          errors << error
          break if errors.length >= limit
        end
        errors
      end

      def last_error_message
        recent_errors(1).first.try(:[], :subject) || ""
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

      private

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
    end
  end
end

