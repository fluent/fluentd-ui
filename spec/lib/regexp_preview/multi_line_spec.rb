require 'spec_helper'

describe RegexpPreview::MultiLine do
  describe "#matches_json" do
    subject { parser.matches_json }
    let(:parser) { RegexpPreview::MultiLine.new(target_path, "multiline", params) }

    describe "simple usage" do
      let(:target_path) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }

      let :params do
        params = {
          format_firstline: "foo",
          time_format: "time_format",
        }
        params["format1"] = "(?<foo>foo)\n"
        params["format2"] = "(?<bar>bar)"
        3.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
          params["format#{i}"] = ""
        end
        { params: params }
      end

      it 'should not have regexp and time_format in [:params][:setting]' do
        expect(subject[:params][:setting]).to eq({ regexp: nil, time_format: nil })
      end

      it "should include matches info" do
        matches_info = {
          whole: "foo\nbar",
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
      let(:params) do
        params = {
          format_firstline: "foo",
          time_format: "time_format",
        }
        params["format1"] = "(?<foo>foo)\n"
        params["format2"] = "(?<bar>baz)"
        3.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
          params["format#{i}"] = ""
        end
        { params: params }
      end

      it "shouldn't match" do
        expect(subject[:matches]).to eq []
      end
    end

    describe "example on document" do
      # http://docs.fluentd.org/articles/in_tail
      let(:target_path) { File.expand_path("./spec/support/fixtures/multiline_example.log", Rails.root) }

      let :params do
        params = {
          format_firstline: "\\d{4}-\\d{1,2}-\\d{1,2}",
          "format1" => "^(?<time>\\d{4}-\\d{1,2}-\\d{1,2} \\d{1,2}:\\d{1,2}:\\d{1,2}) \\[(?<thread>.*)\\] (?<level>[^\\s]+)(?<message>.*)",
          time_format: "time_format",
        }
        2.upto(Fluentd::Setting::InTail::MULTI_LINE_MAX_FORMAT_COUNT) do |i|
          params["format#{i}"] = ""
        end
        { params: params }
      end

      it "should include matches info" do
        matches_info = 
          [
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
