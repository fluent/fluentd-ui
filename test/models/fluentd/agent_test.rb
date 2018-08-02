require "test_helper"

class Fluentd
  class AgentTest < ActiveSupport::TestCase
    module CommonBehavior
      extend ActiveSupport::Concern
      included do
        sub_test_case "#extra_options" do
          test "blank" do
            @agent = @klass.new({})
            assert_equal({}, @agent.extra_options)
            extra_options = {
              config_file: @agent.config_file,
              log_file: @agent.log_file,
              pid_file: @agent.pid_file
            }
            assert_equal(extra_options, @klass.default_options)
          end

          test "given" do
            options = {
              config_file: "pid",
              log_file: "log",
              pid_file: "config"
            }
            @agent = @klass.new(options)
            extra_options = {
              config_file: @agent.config_file,
              log_file: @agent.log_file,
              pid_file: @agent.pid_file
            }
            assert_equal(extra_options, options)
          end
        end

        sub_test_case "#errors_since" do
          setup do
            @logged_time = Time.parse('2014-05-27')
            @now = Time.parse("2014-05-29")
            Timecop.freeze(@now)
          end

          teardown do
            Timecop.return
          end

          test "have no errors" do
            stub(@agent).log_file { fixture_path("error0.log") }
            assert do
              @agent.log.errors_since(100.days.ago).empty?
            end
          end

          sub_test_case "have errors" do
            test "unreachable since 0 days ago" do
              stub(@agent).log_file { fixture_path("error2.log") }
              assert_equal([], @agent.log.errors_since(0.days.ago))
            end

            test "reachable since 100 days ago" do
              stub(@agent).log_file { fixture_path("error2.log") }
              logs = @agent.log.errors_since(100.days.ago)
              assert do
                logs[0][:subject].include?("Address already in use - bind(2)")
              end
              one = Time.parse(logs[0][:subject])
              two = Time.parse(logs[1][:subject])
              assert do
                one >= two
              end
            end
          end
        end

        sub_test_case "#recent_errors" do
          test "have 0 error log" do
            stub(@agent).log_file { fixture_path("error0.log") }
            assert do
              @agent.log.recent_errors(2).empty?
            end
          end

          sub_test_case "have 2 error log" do
            setup do
              stub(@agent).log_file { fixture_path("error2.log") }
            end

            data("limit 1" => 1,
                 "limit 2" => 2)
            test "limit" do |limit|
              assert do
                limit == @agent.log.recent_errors(limit).size
              end
            end

            test "contains stack trace" do
              logs = @agent.log.recent_errors(2)
              assert do
                logs[0][:subject].include?("Address already in use - bind(2)")
              end
            end

            test "newer(bottom) is first" do
              logs = @agent.log.recent_errors(2)
              one = Time.parse(logs[0][:subject])
              two = Time.parse(logs[1][:subject])
              assert do
                one >= two
              end
            end
          end

          sub_test_case "have 3 errors log including sequential 2 error log" do
            setup do
              stub(@agent).log_file { fixture_path("error3.log") }
            end

            test "count 3 errors" do
              logs = @agent.log.recent_errors(3)
              assert_equal(logs[0][:subject].slice(/::EADDRINUSE: (\d) Address already in use/, 1), "3")
              assert_equal(logs[0][:notes].size, 1)
              assert_equal(logs[1][:subject].slice(/::EADDRINUSE: (\d) Address already in use/, 1), "2")
              assert_equal(logs[1][:notes].size, 2)
              assert_equal(logs[2][:subject].slice(/::EADDRINUSE: (\d) Address already in use/, 1), "1")
              assert_equal(logs[2][:notes].size, 0)
            end
          end
        end

        sub_test_case "#dryrun" do
          setup do
            pend("/usr/sbin/td-agent does not exist") unless File.exist?("/usr/sbin/td-agent")
            @root = FluentdUI.data_dir + "/tmp/agent-test/"
            @dummy_log_file = @root + "dummy.log"
            @dummy_pid_file = @root + "dummy.pid"

            FileUtils.mkdir_p(@root)
            stub(@agent).log_file { @dummy_log_file }
            stub(@agent).pid_file { @dummy_pid_file }
          end

          sub_test_case "valid/invalid" do
            setup do
              @config_path = Rails.root.join("tmp", "fluent-test.conf").to_s
            end

            teardown do
              File.unlink(@config_path) if @config_path && File.exist?(@config_path)
            end

            test "valid config" do
              config = <<-CONF.strip_heredoc
              <source>
                @type forward
              </source>
              CONF
              File.write(@config_path, config)
              assert_nothing_raised do
                @agent.dryrun!(@config_path)
              end
              assert_true(@agent.dryrun(@config_path))
            end

            test "invalid config" do
              config = <<-CONF.strip_heredoc
              <source>
                @type forward
              CONF
              File.write(@config_path, config)
              assert_raise(Fluentd::Agent::ConfigError) do
                @agent.dryrun!(@config_path)
              end
              assert_false(@agent.dryrun(@config_path))
            end
          end
        end
      end
    end

    module RestartStrategy
      extend ActiveSupport::Concern

      included do
        setup do
          options = {
            config_file: Rails.root.join("tmp", "fluentd-test", "fluentd.conf").to_s
          }
          @klass = Fluentd::Agent::FluentdGem
          @agent = @klass.new(options)
        end

        data("succeeded to start" => true,
             "failed to stard" => false)
        test "not running" do |start|
          stub(@agent).running? { false }
          stub(@agent).start { start }
          assert_equal(start, @agent.restart)
        end

        sub_test_case "running" do
          data("stop: success, start: success" => [true, true, true],
               "stop: success, start: failure" => [true, false, false],
               "stop: failure, start: success" => [false, true, false],
               "stop: failure, start: failure" => [false, false, false])
          test "#validate_fluentd_options success" do |(stop_result, start_result, restarted)|
            stub(@agent).validate_fluentd_options { true }
            stub(@agent).running? { true }
            stub(@agent).start { stop_result }
            stub(@agent).stop { start_result }
            assert_equal(restarted, @agent.restart)
          end

          data("stop: success, start: success" => [true, true, false],
               "stop: success, start: failure" => [true, false, false],
               "stop: failure, start: success" => [false, true, false],
               "stop: failure, start: failure" => [false, false, false])
          test "#validate_fluentd_options failure" do
            stub(@agent).validate_fluentd_options { false }
            stub(@agent).running? { true }
            stub(@agent).start { stop_result }
            stub(@agent).stop { start_result }
            assert_equal(restarted, @agent.restart)
          end
        end
      end
    end

    sub_test_case "FluentdGem" do
      setup do
        options = {
          config_file: Rails.root.join("tmp", "fluentd-test", "fluentd.conf").to_s
        }
        @klass = Fluentd::Agent::FluentdGem
        @agent = @klass.new(options)
      end

      include CommonBehavior

      test "#options_to_argv" do
        expected_argv = " -c #{@agent.config_file} -d #{@agent.pid_file} -o #{@agent.log_file}"
        assert_equal(expected_argv, @agent.__send__(:options_to_argv))
      end

      sub_test_case "#start" do
        setup do
          # ensure valid config
          @agent.config_write("")
        end

        teardown do
          FileUtils.rm_rf(@agent.running_config_backup_dir)
        end

        test "running" do
          stub(@agent).running? { true }
          assert_true(@agent.start)
        end

        test "succeeded to actual_start" do
          stub(@agent).running? { false }
          stub(@agent).actual_start { true }
          assert_true(@agent.start)
          backup_file = @agent.running_config_backup_file
          assert do
            File.exist?(backup_file)
          end
          assert_equal(File.read(@agent.config_file), File.read(backup_file))
        end

        test "failed to actual_start" do
          stub(@agent).running? { false }
          stub(@agent).actual_start { false }
          assert_nil(@agent.start)
        end
      end

      sub_test_case "#stop" do
        data("succeeded to actual_stop" => true,
             "failed to actual_stop" => false)
        test "running" do |stop_result|
          stub(@agent).running? { true }
          stub(@agent).actual_stop { stop_result }
          assert_equal(stop_result, @agent.stop)
        end

        test "not running" do
          stub(@agent).running? { false }
          assert do
            @agent.stop
          end
        end
      end

      sub_test_case "#restart" do
        include RestartStrategy
      end
    end

    sub_test_case "TdAgent" do
      setup do
        options = {
          config_file: Rails.root.join("tmp", "fluentd-test", "fluentd.conf").to_s
        }
        @klass = Fluentd::Agent::TdAgent
        @agent = @klass.new(options)
      end

      include CommonBehavior

      sub_test_case "#backup_running_config" do
        setup do
          stub(@agent).detached_command { true }
          stub(@agent).pid_from_launchctl { true }
          @agent.config_write("") # ensure valid config
        end

        teardown do
          FileUtils.rm_rf(@agent.running_config_backup_dir)
        end


        test "backup running conf" do
          @agent.start
          backup_file = @agent.running_config_backup_file
          assert_true(File.exist?(backup_file))
          assert_equal(File.read(@agent.config_file), File.read(backup_file))
        end
      end
    end
  end
end
