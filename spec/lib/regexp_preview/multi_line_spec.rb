require 'spec_helper'

describe RegexpPreview::MultiLine do
  describe "#matches" do
    subject { parser.matches }
    let(:parser) { RegexpPreview::MultiLine.new(target_path, "multiline", plugin_config) }

    describe "simple usage" do
      let(:target_path) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }

      let :plugin_config do
        plugin_config = {
          "format_firstline" => "/foo/",
          "time_format" => "time_format",
        }
        plugin_config["format1"] = "/(?<foo>foo)\n/"
        plugin_config["format2"] = "/(?<bar>bar)/"
        3.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
          plugin_config["format#{i}"] = "//"
        end
        plugin_config
      end

      it "should include matches info" do
        matches_info = {
          whole: "foo\nbar\nbaz\n1\n2\n3\n4\n5\n6\n10\n11\n12",
          matches: [
            {
              key: "foo", matched: "foo", pos: [0, 3]
            },
            {
              key: "bar", matched: "bar", pos: [4, 7]
            }
          ]
        }
        expect(subject[:matches]).to include matches_info
      end
    end

    describe "detect only continuos patterns" do
      let(:target_path) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }
      let(:plugin_config) do
        plugin_config = {
          "format_firstline" => "/foo/",
          "time_format" => "time_format",
        }
        plugin_config["format1"] = "/(?<foo>foo)\n/"
        plugin_config["format2"] = "/(?<bar>baz)/"
        3.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
          plugin_config["format#{i}"] = "//"
        end
        plugin_config
      end

      it "shouldn't match" do
        expect(subject[:matches]).to eq []
      end
    end

    describe "example on document" do
      # http://docs.fluentd.org/articles/in_tail
      let(:target_path) { File.expand_path("./spec/support/fixtures/multiline_example.log", Rails.root) }

      let :plugin_config do
        plugin_config = {
          "format_firstline" => "/\\d{4}-\\d{1,2}-\\d{1,2}/",
          "format1" => "/^(?<time>\\d{4}-\\d{1,2}-\\d{1,2} \\d{1,2}:\\d{1,2}:\\d{1,2}) \\[(?<thread>.*)\\] (?<level>[^\\s]+)(?<message>.*)/",
          "time_format" => "%Y-%m-%d %H:%M:%S",
          "keep_time_key" => true
        }
        2.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
          plugin_config["format#{i}"] = "//"
        end
        plugin_config
      end

      it "should include matches info" do
        matches_info = [
            {
              whole: "2013-3-03 14:27:33 [main] INFO  Main - Start\n",
              matches: [
                {key: "time", matched: "2013-3-03 14:27:33", pos: [0, 18]},
                {key: "thread", matched: "main", pos: [20, 24]},
                {key: "level", matched: "INFO", pos: [26, 30]},
                {key: "message", matched: "  Main - Start\n", pos: [30, 45]}
              ]
            },
            {
              whole: "2013-3-03 14:27:33 [main] ERROR Main - Exception\njavax.management.RuntimeErrorException: null\n    at Main.main(Main.java:16) ~[bin/:na]\n",
              matches: [
                {key: "time", matched: "2013-3-03 14:27:33", pos: [0, 18]},
                {key: "thread", matched: "main", pos: [20, 24]},
                {key: "level", matched: "ERROR", pos: [26, 31]},
                {key: "message", matched: " Main - Exception\njavax.management.RuntimeErrorException: null\n    at Main.main(Main.java:16) ~[bin/:na]\n", pos: [31, 136]},
              ]
            },
            {
              whole: "2013-3-03 14:27:33 [main] INFO  Main - End",
              matches: [
                {key: "time", matched: "2013-3-03 14:27:33", pos: [0, 18]},
                {key: "thread", matched: "main", pos: [20, 24]},
                {key: "level", matched: "INFO", pos: [26, 30]},
                {key: "message", matched: "  Main - End", pos: [30, 42]},
              ]
            }
        ]
        expect(subject[:matches]).to eq matches_info
      end
    end
  end
end
