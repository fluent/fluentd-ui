require "enumerator"
require 'spec_helper'

describe FileReverseReader do
  describe "#each_line" do
    let(:instance) { FileReverseReader.new(io, step) }
    let(:io) { File.open(logfile) }

    subject { instance.enum_for(:each_line) }

    context "read at once" do
      let(:logfile) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }

      context "small file (read at once)" do
        let(:step) { File.size(logfile) }

        it { subject.count.should == File.open(logfile).each_line.count }
        it "reverse order" do
          subject.to_a.should == File.open(logfile).each_line.to_a.map(&:strip).reverse
        end
      end

      context "large file" do
        let(:step) { 2 }

        it { subject.count.should == File.open(logfile).each_line.count }
        it "reverse order" do
          subject.to_a.should == File.open(logfile).each_line.to_a.map(&:strip).reverse
        end
      end
    end
  end
end

