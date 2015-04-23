require 'spec_helper'

describe RegexpPreview::SingleLine do
  describe ".initialize" do
    subject { RegexpPreview::SingleLine.new("log_file.log", format, params) }

    describe "format" do
      let :params do
        {
          time_format: "time_format",
          regexp: "(?<category>\[.+\])",
        }
      end

      shared_examples "should set regexp and time_format from selected format" do
        it do
          expect(subject.regexp).to eq regexp
          expect(subject.time_format).to eq time_format
          expect(subject.params).to eq params
        end
      end

      shared_examples "should set params only" do
        include_examples "should set regexp and time_format from selected format" do
          let(:regexp) { nil }
          let(:time_format) { nil }
        end
      end

      context "regexp" do
        let(:format) { "regexp" }

        it 'should set regexp from params' do
          expect(subject.regexp).to eq /#{params[:regexp]}/
          expect(subject.time_format).to be_nil
          expect(subject.params).to eq params
        end
      end

      context "ltsv" do
        let(:format) { "ltsv" }

        include_examples "should set params only"
      end

      context "json" do
        let(:format) { "json" }

        include_examples "should set params only"
      end

      context "csv" do
        let(:format) { "csv" }

        include_examples "should set params only"
      end

      context "tsv" do
        let(:format) { "tsv" }

        include_examples "should set params only"
      end

      context "syslog" do # "apache", "nginx", etc
        let(:format) { "syslog" }

        include_examples "should set regexp and time_format from selected format" do
          let(:regexp) do
            /^(?<time>[^ ]*\s*[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$/
          end
          let(:time_format) { "%b %d %H:%M:%S" }
        end
      end

      context "apache" do
        let(:format) { "apache" }

        include_examples "should set regexp and time_format from selected format" do
          let(:regexp) do
            /^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$/
          end
          let(:time_format) { "%d/%b/%Y:%H:%M:%S %z" }
        end
      end

      context "nginx" do
        let(:format) { "nginx" }

        include_examples "should set regexp and time_format from selected format" do
          let(:regexp) do
            /^(?<remote>[^ ]*) (?<host>[^ ]*) (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$/
          end
          let(:time_format) { "%d/%b/%Y:%H:%M:%S %z" }
        end
      end
    end
  end

  describe "#matches_json" do
    let(:logfile) { File.expand_path(logfile_path, Rails.root) }
    let :params do
      {
        regexp: "(?<regexp>bar)", # bar from error0.log
        time_format: "time_format",
      }
    end

    subject { RegexpPreview::SingleLine.new(logfile, format, params).matches_json }

    describe "format" do
      context "regexp" do
        let(:format) { "regexp" }
        let(:logfile_path) { "./spec/support/fixtures/error0.log" }

        it 'should have regexp only in [:params][:setting]' do
          setting_json = {
            regexp: params[:regexp],
            time_format: nil
          }

          expect(subject[:params][:setting]).to eq setting_json
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
        let(:format) { "csv" }
        let(:logfile_path) { "./spec/support/fixtures/error0.log" }

        it 'should not have regexp and time_format in [:params][:setting]' do
          setting_json = {
            regexp: nil,
            time_format: nil
          }

          expect(subject[:params][:setting]).to eq setting_json
        end

        it 'should not have matches_info' do
          expect(subject[:matches]).to be_empty
        end
      end

      context "syslog" do
        let(:format) { "syslog" }
        let(:logfile_path) { "./spec/support/fixtures/error4.log" }

        it 'should set regexp and time_format from syslog format' do
          setting_json = {
            regexp: "^(?<time>[^ ]*\\s*[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_/\\.\\-]*)(?:\\[(?<pid>[0-9]+)\\])?(?:[^\\:]*\\:)? *(?<message>.*)$",
            time_format: "%b %d %H:%M:%S",
          }

          expect(subject[:params][:setting]).to eq setting_json
        end

        it 'should include matches info' do
          matches_info = {
            whole: "2014-05-27 10:54:37 +0900 [info]: listening fluent socket on 0.0.0.0:24224",
            matches: [
              { key: "time", matched: "2014-05-27 10:54:37 +0900", pos: [0, 25] },
              { key: "host", matched: "[info]:", pos: [26, 33] },
              { key: "ident", matched: "listening", pos: [34, 43] },
              { key: "pid", matched: nil, pos: [nil, nil] },
              { key: "message", matched: "24224", pos: [69, 74] }
            ]
          }

          expect(subject[:matches]).to include matches_info
        end
      end
    end
  end
end
