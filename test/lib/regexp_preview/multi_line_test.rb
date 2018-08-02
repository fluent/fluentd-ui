require "test_helper"

module RegexpPreview
  class MultilineTest < ActiveSupport::TestCase
    test "simple usage" do
      config = {
        "format_firstline" => "/foo/",
        "time_format" => "time_format",
      }
      config["format1"] = "/(?<foo>foo)\n/"
      config["format2"] = "/(?<bar>bar)/"
      3.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
        config["format#{i}"] = "//"
      end
      preview = RegexpPreview::MultiLine.new(fixture_path("error0.log"), "multiline", config)
      matches = [
        {
          whole: "foo\nbar\nbaz\n1\n2\n3\n4\n5\n6\n10\n11\n12",
          matches: [
            { key: "foo", matched: "foo", pos: [0, 3] },
            { key: "bar", matched: "bar", pos: [4, 7] }
          ]
        }
      ]
      assert_equal(matches, preview.matches[:matches])
    end

    test "detect only continuous patterns" do
      config = {
        "format_firstline" => "/foo/",
        "time_format" => "time_format",
      }
      config["format1"] = "/(?<foo>foo)\n/"
      config["format2"] = "/(?<bar>baz)/"
      3.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
        config["format#{i}"] = "//"
      end
      preview = RegexpPreview::MultiLine.new(fixture_path("error0.log"), "multiline", config)
      assert_equal([], preview.matches[:matches])
    end

    # http://docs.fluentd.org/articles/in_tail
    test "example on document" do
      config = {
        "format_firstline" => "/\\d{4}-\\d{1,2}-\\d{1,2}/",
        "format1" => "/^(?<time>\\d{4}-\\d{1,2}-\\d{1,2} \\d{1,2}:\\d{1,2}:\\d{1,2}) \\[(?<thread>.*)\\] (?<level>[^\\s]+)(?<message>.*)/",
        "time_format" => "%Y-%m-%d %H:%M:%S",
        "keep_time_key" => true
      }
      2.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
        config["format#{i}"] = "//"
      end
      preview = RegexpPreview::MultiLine.new(fixture_path("multiline_example.log"), "multiline", config)
      matches = [
            {
              whole: "2013-3-03 14:27:33 [main] INFO  Main - Start\n",
              matches: [
                { key: "time", matched: "2013-3-03 14:27:33", pos: [0, 18] },
                { key: "thread", matched: "main", pos: [20, 24] },
                { key: "level", matched: "INFO", pos: [26, 30] },
                { key: "message", matched: "  Main - Start\n", pos: [30, 45] }
              ]
            },
            {
              whole: "2013-3-03 14:27:33 [main] ERROR Main - Exception\njavax.management.RuntimeErrorException: null\n    at Main.main(Main.java:16) ~[bin/:na]\n",
              matches: [
                { key: "time", matched: "2013-3-03 14:27:33", pos: [0, 18] },
                { key: "thread", matched: "main", pos: [20, 24] },
                { key: "level", matched: "ERROR", pos: [26, 31] },
                { key: "message", matched: " Main - Exception\njavax.management.RuntimeErrorException: null\n    at Main.main(Main.java:16) ~[bin/:na]\n", pos: [31, 136] },
              ]
            },
            {
              whole: "2013-3-03 14:27:33 [main] INFO  Main - End",
              matches: [
                { key: "time", matched: "2013-3-03 14:27:33", pos: [0, 18] },
                { key: "thread", matched: "main", pos: [20, 24] },
                { key: "level", matched: "INFO", pos: [26, 30] },
                { key: "message", matched: "  Main - End", pos: [30, 42] },
              ]
            }
      ]
      assert_equal(matches, preview.matches[:matches])
    end
  end
end
