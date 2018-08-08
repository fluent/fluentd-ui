require "test_helper"

class FluentdLogTest < ActiveSupport::TestCase
  sub_test_case "#read" do
    setup do
      @logfile = Rails.root.join("tmp", "dummylog").to_s
      @log = FluentdLog.new(@logfile)
    end

    test "compatible with utf-8" do
      content = "utf8あいう\n"
      File.write(@logfile, content)
      assert_equal(content, @log.read)
    end

    test "incompatible with utf-8" do
      content = "eucあいう\n".encode('euc-jp').force_encoding('ascii-8bit')
      File.open(@logfile, "wb") {|file| file.write(content) }
      assert_equal(content, @log.read)
    end
  end

  sub_test_case "#tail" do
    setup do
      @logfile = Rails.root.join("tmp", "dummylog").to_s
      @log = FluentdLog.new(@logfile)
      File.open(@logfile, "wb") do |file|
        5.times do |n|
          file.puts(n)
        end
      end
    end

    data("tail(5)" => [5, %w(4 3 2 1 0)],
         "tail(3)" => [3, %w(4 3 2)],
         "tail(99)" => [99, %w(4 3 2 1 0)])
    test "5 line log" do |(limit, expected)|
      assert_equal(@log.tail(limit), expected)
    end
  end

  sub_test_case "#logged_errors" do
    data("have 0 error log" => "error0.log",
         "have error log" => "error2.log")
    test "#last_error_message" do |path|
      logfile = fixture_path(path)
      log = FluentdLog.new(logfile)
      if path == "error0.log"
        assert do
          log.last_error_message.empty?
        end
      else
        assert_equal(log.last_error_message, log.recent_errors(1).first[:subject])
      end
    end

    sub_test_case "#errors_since" do
      setup do
        @logged_time = Time.parse("2014-05-27")
        @now = Time.parse("2014-05-29")
        Timecop.freeze(@now)
      end

      teardown do
        Timecop.return
      end

      test "have no errors" do
        log = FluentdLog.new(fixture_path("error0.log"))
        assert do
          log.errors_since(100.days.ago).empty?
        end
      end

      sub_test_case "have errors" do
        setup do
          @log = FluentdLog.new(fixture_path("error2.log"))
        end

        test "unreachable since" do
          assert do
            @log.errors_since(0.days.ago).empty?
          end
        end

        test "reachable since" do
          errors = @log.errors_since(100.days.ago)
          assert_equal("unexpected error error_class=Errno::EADDRINUSE error=#<Errno::EADDRINUSE: Address already in use - bind(2) for \"0.0.0.0\" port 24224>",
                       errors[0][:subject].slice(/\[error\]: (.+)/, 1))
          assert do
            Time.parse(errors[0][:subject]) >= Time.parse(errors[1][:subject])
          end
        end
      end
    end

    sub_test_case "recent_errors" do
      test "have 0 error log" do
        log = FluentdLog.new(fixture_path("error0.log"))
        assert do
          log.recent_errors(2).empty?
        end
      end

      sub_test_case "have 2 error log" do
        setup do
          @log = FluentdLog.new(fixture_path("error2.log"))
        end

        data("limit=1" => 1,
             "limit=2" => 2)
        test "limit" do |limit|
          assert_equal(limit, @log.recent_errors(limit).length)
        end

        test "contains stack trace" do
          errors = @log.recent_errors(2)
          assert_equal("unexpected error error_class=Errno::EADDRINUSE error=#<Errno::EADDRINUSE: Address already in use - bind(2) for \"0.0.0.0\" port 24224>",
                       errors[0][:subject].slice(/\[error\]: (.+)/, 1))
          assert do
            Time.parse(errors[0][:subject]) >= Time.parse(errors[1][:subject])
          end
        end
      end

      sub_test_case "have 3 errors including sequential 2 error log" do
        test "count 3 errors" do
          log = FluentdLog.new(fixture_path("error3.log"))
          errors = log.recent_errors(3)
          assert_equal(errors[0][:subject].slice(/::EADDRINUSE: (\d) Address already in use/, 1), "3")
          assert_equal(errors[0][:notes].size, 1)
          assert_equal(errors[1][:subject].slice(/::EADDRINUSE: (\d) Address already in use/, 1), "2")
          assert_equal(errors[1][:notes].size, 2)
          assert_equal(errors[2][:subject].slice(/::EADDRINUSE: (\d) Address already in use/, 1), "1")
          assert_equal(errors[2][:notes].size, 0)
        end
      end
    end
  end
end
