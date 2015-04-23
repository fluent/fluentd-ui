require 'spec_helper'

describe RegexpPreview::MultiLine do
  describe "#matches_json" do
    subject { RegexpPreview::MultiLine.new(File.expand_path("./spec/support/fixtures/error0.log", Rails.root), "multiline", params).matches_json }

    let :params do
      params = {
        format_firstline: ".+",
        time_format: "time_format",
      }
      params["format1"] = "(?<foo>foo)"
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
        whole: "foo\nbar\n",
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
end
