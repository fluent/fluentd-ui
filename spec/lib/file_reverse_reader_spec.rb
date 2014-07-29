require "enumerator"
require 'spec_helper'

describe FileReverseReader do
  let(:instance) { FileReverseReader.new(io) }
  let(:io) { File.open(logfile) }

  describe "#each_line" do
    let(:instance) { FileReverseReader.new(io, step) }
    subject { instance.enum_for(:each_line) }
    let(:logfile) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }

    context "read at once" do

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

  describe "#binary_file?" do
    let(:logfile) { File.expand_path("./tmp/log.log", Rails.root) }
    before { File.open(logfile, "wb"){|f| f.write content} }
    subject { instance.binary_file? }

    context "contain ascii only" do
      let(:content) { "ABCDE" }
      it { should be_false }
    end

    context "contain non-ascii" do
      let(:content) { "\x89NG" }
      it { should be_true }
    end
  end

  describe "#tail" do
    let(:logfile) { File.expand_path("./tmp/log.log", Rails.root) }
    let(:log_lines) { 100 }
    before { File.open(logfile, "w"){|f| f.write("foo\n" * log_lines) } }
    subject { instance.tail(count) }

    context "2" do
      let(:count) { 2 }
      it { subject.to_a.size.should == count }
    end

    context "50" do
      let(:count) { 50 }
      it { subject.to_a.size.should == count }
    end

    context "over log lines" do
      let(:count) { log_lines + 100 }
      it { subject.to_a.size.should == log_lines }
    end
  end
end

