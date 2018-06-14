require 'spec_helper'

describe RegexpPreview::SingleLine do
  describe ".initialize" do
    subject { RegexpPreview::SingleLine.new("log_file.log", plugin_name, plugin_config) }

    describe "parse" do
      let :plugin_config do
        {}
      end

      shared_examples "should create parser plugin instance from selected plugin name" do
        it do
          expect(subject.plugin).to(be_an_instance_of(plugin_class))
        end
      end

      context "regexp" do
        let(:plugin_name) { "regexp" }
        let(:plugin_class) { Fluent::Plugin::RegexpParser }
        let :plugin_config do
          {
            "expression" => "(?<category>\[.+\])",
            "time_format" => "%y/%m/%d",
          }
        end
        include_examples("should create parser plugin instance from selected plugin name")
      end

      context "ltsv" do
        let(:plugin_name) { "ltsv" }
        let(:plugin_class) { Fluent::Plugin::LabeledTSVParser }

        include_examples("should create parser plugin instance from selected plugin name")
      end

      context "json" do
        let(:plugin_name) { "json" }
        let(:plugin_class) { Fluent::Plugin::JSONParser }

        include_examples("should create parser plugin instance from selected plugin name")
      end

      context "csv" do
        let(:plugin_name) { "csv" }
        let(:plugin_class) { Fluent::Plugin::CSVParser }
        let(:plugin_config) do
          {
            "keys" => "column1,column2"
          }
        end

        include_examples("should create parser plugin instance from selected plugin name")
      end

      context "tsv" do
        let(:plugin_name) { "tsv" }
        let(:plugin_class) { Fluent::Plugin::TSVParser }
        let(:plugin_config) do
          {
            "keys" => "column1,column2"
          }
        end

        include_examples("should create parser plugin instance from selected plugin name")
      end

      context "syslog" do # "apache", "nginx", etc
        let(:plugin_name) { "syslog" }
        let(:plugin_class) { Fluent::Plugin::SyslogParser }

        include_examples("should create parser plugin instance from selected plugin name")
      end

      context "apache" do
        let(:plugin_name) { "apache" }
        let(:plugin_class) { Fluent::Plugin::ApacheParser }

        include_examples("should create parser plugin instance from selected plugin name")
      end

      context "nginx" do
        let(:plugin_name) { "nginx" }
        let(:plugin_class) { Fluent::Plugin::NginxParser }

        include_examples("should create parser plugin instance from selected plugin name")
      end
    end
  end

  describe "#matches" do
    let(:logfile) { File.expand_path(logfile_path, Rails.root) }
    subject { RegexpPreview::SingleLine.new(logfile, plugin_name, plugin_config).matches }

    describe "parse" do
      context "regexp" do
        let(:plugin_name) { "regexp" }
        let(:logfile_path) { "./spec/support/fixtures/error0.log" }
        let :plugin_config do
          {
            "expression" => "(?<regexp>bar)", # bar from error0.log
            "time_format" => "time_format",
          }
        end

        it 'should have regexp only in [:params][:setting]' do
          expect(subject[:pluginConfig]).to eq plugin_config
        end

        it 'should include matches info' do
          matches_info = {
            whole: "bar",
            matches: [
              { key: "regexp", matched: "bar", pos: [0, 3] }
            ]
          }
          expect(subject[:matches]).to include matches_info
        end
      end

      context "csv" do
        let(:plugin_name) { "csv" }
        let(:logfile_path) { "./spec/support/fixtures/error0.log" }
        let :plugin_config do
          {
            "keys" => "column1,column2"
          }
        end

        it 'should not have matches_info' do
          expect(subject[:matches]).to be_empty
        end
      end

      context "syslog" do
        let(:logfile_path) { "./spec/support/fixtures/error4.log" }
        let(:plugin_name) { "syslog" }
        let(:plugin_config) do
          {
            "time_format" => "%Y-%m-%d %H:%M:%S %z",
            "keep_time_key" => true
          }
        end

        it 'should include matches info' do
          matches_info = {
            whole: "2014-05-27 10:54:37 +0900 [info]: listening fluent socket on 0.0.0.0:24224",
            matches: [
              { key: "time", matched: "2014-05-27 10:54:37 +0900", pos: [0, 25] },
              { key: "host", matched: "[info]:", pos: [26, 33] },
              { key: "ident", matched: "listening", pos: [34, 43] },
              { key: "message", matched: "24224", pos: [69, 74] }
            ]
          }

          expect(subject[:matches]).to include matches_info
        end
      end

      context "syslog when keep_time_key is false" do
        let(:logfile_path) { "./spec/support/fixtures/error4.log" }
        let(:plugin_name) { "syslog" }
        let(:plugin_config) do
          {
            "time_format" => "%Y-%m-%d %H:%M:%S %z",
            "keep_time_key" => false
          }
        end

        it 'should include matches info' do
          matches_info = {
            whole: "2014-05-27 10:54:37 +0900 [info]: listening fluent socket on 0.0.0.0:24224",
            matches: [
              { key: "host", matched: "[info]:", pos: [26, 33] },
              { key: "ident", matched: "listening", pos: [34, 43] },
              { key: "message", matched: "24224", pos: [69, 74] }
            ]
          }

          expect(subject[:matches]).to include matches_info
        end
      end
    end
  end
end
