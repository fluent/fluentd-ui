require "test_helper"
require "fluent/plugin/parser_apache"
require "fluent/plugin/parser_nginx"

module RegexpPreview
  class SingleLineTest < ActiveSupport::TestCase
    data("regexp" => ["regexp", Fluent::Plugin::RegexpParser, { "expression" => "(?<catefory>\[.+\])", "time_format" => "%Y/%m/%d" }],
         "ltsv" => ["ltsv", Fluent::Plugin::LabeledTSVParser, {}],
         "json" => ["json", Fluent::Plugin::JSONParser, {}],
         "csv" => ["csv", Fluent::Plugin::CSVParser, { "keys" => "column1,column2" }],
         "tsv" => ["tsv", Fluent::Plugin::TSVParser, { "keys" => "column1,column2" }],
         "syslog" => ["syslog", Fluent::Plugin::SyslogParser, {}],
         "apache" => ["apache", Fluent::Plugin::ApacheParser, {}],
         "nginx" => ["nginx", Fluent::Plugin::NginxParser, {}])
    test "create parser plugin instance from selected plugin name" do |(name, klass, config)|
      preview = RegexpPreview::SingleLine.new("log_file.log", name, config)
      assert_instance_of(klass, preview.plugin)
    end

    sub_test_case "#matches" do
      test "regexp" do
        config = {
          "expression" => "(?<regexp>bar)", # bar from error0.log
          "time_format" => "time_format",
        }
        preview = RegexpPreview::SingleLine.new(fixture_path("error0.log"), "regexp", config)
        matches = [
          {
            whole: "bar",
            matches: [
              { key: "regexp", matched: "bar", pos: [0, 3] }
            ]
          }
        ]
        assert_equal(config, preview.matches[:pluginConfig])
        assert_equal(matches,preview.matches[:matches])
      end

      test "csv" do
        config = { "keys" => "column1,column2" }
        preview = RegexpPreview::SingleLine.new(fixture_path("error0.log"), "csv", config)
        assert do
          preview.matches[:matches].empty?
        end
      end

      test "syslog" do
        config = {
          "time_format" => "%Y-%m-%d %H:%M:%S %z",
          "keep_time_key" => true
        }
        preview = RegexpPreview::SingleLine.new(fixture_path("error4.log"), "syslog", config)
        matches = [
          {
            whole: "2014-05-27 10:54:37 +0900 [info]: listening fluent socket on 0.0.0.0:24224",
            matches: [
              { key: "time", matched: "2014-05-27 10:54:37 +0900", pos: [0, 25] },
              { key: "host", matched: "[info]:", pos: [26, 33] },
              { key: "ident", matched: "listening", pos: [34, 43] },
              { key: "message", matched: "24224", pos: [69, 74] }
            ]
          }
        ]
        assert_equal(matches, preview.matches[:matches])
      end

      test "syslog when keep_time_key is false" do
        config = {
          "time_format" => "%Y-%m-%d %H:%M:%S %z",
          "keep_time_key" => false
        }
        preview = RegexpPreview::SingleLine.new(fixture_path("error4.log"), "syslog", config)
        matches = [
          {
            whole: "2014-05-27 10:54:37 +0900 [info]: listening fluent socket on 0.0.0.0:24224",
            matches: [
              { key: "host", matched: "[info]:", pos: [26, 33] },
              { key: "ident", matched: "listening", pos: [34, 43] },
              { key: "message", matched: "24224", pos: [69, 74] }
            ]
          }
        ]
        assert_equal(matches, preview.matches[:matches])
      end
    end
  end
end
