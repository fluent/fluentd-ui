require "test_helper"

module Fluentd::Setting
  class InSyslogTest < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::InSyslog
      @instance = @klass.new({ tag: "foo.bar" })
    end

    test "#valid?" do
      assert do
        @instance.valid?
      end
    end

    test "invalid" do
      assert do
        !@klass.new({}).valid?
      end
    end

    test "#plugin_name" do
      assert_equal("syslog", @instance.plugin_name)
    end

    test "#plugin_type" do
      assert_equal("input", @instance.plugin_type)
    end

    test "#to_config" do
      assert do
        @instance.to_config.to_s.include?("@type syslog")
      end
    end

    test "with parse section" do
      params = {
        tag: "test",
        parse_type: "syslog",
        parse: {
          "0" => {
            "type" => "syslog",
            "message_format" => "rfc5424"
          }
        }
      }
      @instance = @klass.new(params)
      expected = <<-CONFIG.strip_heredoc
        <source>
          @type syslog
          tag test
          <parse>
            @type syslog
            message_format rfc5424
          </parse>
        </source>
      CONFIG
      assert_equal(expected, @instance.to_config.to_s)
    end

    test "with @log_level" do
      params = {
        tag: "test",
        log_level: "debug",
        parse_type: "syslog",
        parse: {
          "0" => {
            "type" => "syslog",
            "message_format" => "rfc5424"
          }
        }
      }
      @instance = @klass.new(params)
      expected = <<-CONFIG.strip_heredoc
        <source>
          @type syslog
          tag test
          @log_level debug
          <parse>
            @type syslog
            message_format rfc5424
          </parse>
        </source>
      CONFIG
      assert_equal(expected, @instance.to_config.to_s)
    end
  end
end
