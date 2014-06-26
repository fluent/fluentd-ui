require 'spec_helper'

describe GrokConverter do
  describe "#convert_to_regexp" do
    let(:grok) { GrokConverter.new }

    subject { grok.convert_to_regexp(pattern) }

    context "load" do
      before { grok.load_patterns(Rails.root + "vendor/patterns/") }

      context "basic key" do
        let(:pattern) { "%{USER:username} is a user" }

        it do
          subject.names.should == ["username"]
        end

        it do
          subject.match("foobar is a user").should be_truthy
        end
      end

      context "without name" do
        let(:pattern) { "%{USER} is a user" }

        it do
          subject.names.should == []
        end

        it do
          subject.match("foobar2 is a user").should be_truthy
        end
      end

      context "not exists key" do
        let(:pattern) { "%{USER:username} %{USER} %{NOT_EXISTS_KEY:key} foo bar" }

        it do
          subject.names.should == ["username", "key"]
        end

        it do
          subject.match("someuser user2  foo bar").should be_truthy
        end
      end
    end
  end
end

