# coding: utf-8
require "spec_helper"

describe FluentdLog do
  describe "#read" do
    let(:log) { FluentdLog.new(logfile) }
    let(:logfile) { Rails.root.join("tmp", "dummylog").to_s }

    before { File.open(logfile, "wb"){|f| f.write content } }
    subject { log.read }

    context "compatible with utf-8" do
      let(:content) { "utf8あいう\n" }
      it { subject.should == content }
    end

    context "incompatible with utf-8" do
      let(:content) { "eucあいう\n".encode('euc-jp').force_encoding('ascii-8bit') }
      it { subject.should == content }
    end
  end

  describe "#tail" do
    let(:log) { FluentdLog.new(logfile) }
    let(:logfile) { Rails.root.join("tmp", "dummylog").to_s }

    before { File.open(logfile, "wb"){|f| f.write content } }

    context "5 lines log" do
      let(:content) { 5.times.map{|n| "#{n}\n"}.join }

      context "tail(5)" do
        let(:limit) { 5 }
        subject { log.tail(limit) }

        it { should == %w(4 3 2 1 0) }
      end

      context "tail(3)" do
        let(:limit) { 3 }
        subject { log.tail(limit) }

        it { should == %w(4 3 2) }
      end

      context "tail(99)" do
        let(:limit) { 99 }
        subject { log.tail(limit) }

        it { should == %w(4 3 2 1 0) }
      end
    end
  end

  describe "#logged_errors" do
    let(:log) { FluentdLog.new(logfile) }

    describe "#last_error_message" do
      subject { log.last_error_message }

      context "have 0 error log" do
        let(:logfile) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }

        it { should be_empty }
      end

      context "have 2 error log" do
        let(:logfile) { File.expand_path("./spec/support/fixtures/error2.log", Rails.root) }

        it { should == log.recent_errors(1).first[:subject] }
      end
    end

    describe "#errors_since" do
      let(:logged_time) { Time.parse('2014-05-27') }
      let(:now) { Time.parse('2014-05-29') }

      before { Timecop.freeze(now) }
      after { Timecop.return }

      subject { log.errors_since(days.days.ago) }

      context "has no errors" do
        let(:logfile) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }
        let(:days) { 100 }

        it "empty array" do
          should be_empty
        end
      end

      context "has errors" do
        let(:logfile) { File.expand_path("./spec/support/fixtures/error2.log", Rails.root) }

        context "unreachable since" do
          let(:days) { 0 }
          it { should be_empty }
        end

        context "reachable since" do
          let(:days) { 100 }

          it "contain stack trace" do
            subject[0][:subject].should include("Address already in use - bind(2)")
          end

          it "newer(bottom) is first" do
            one = Time.parse(subject[0][:subject])
            two = Time.parse(subject[1][:subject])
            one.should >= two
          end
        end
      end
    end

    describe "#recent_errors" do
      context "have 0 error log" do
        let(:logfile) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }
        subject { log.recent_errors(2) }

        it "empty array" do
          should be_empty
        end
      end

      context "have 2 error log" do
        let(:logfile) { File.expand_path("./spec/support/fixtures/error2.log", Rails.root) }
        subject { log.recent_errors(2) }

        describe "limit" do
          subject { log.recent_errors(limit).length }

          context "=1" do
            let(:limit) { 1 }
            it { should == limit }
          end

          context "=2" do
            let(:limit) { 2 }
            it { should == limit }
          end
        end

        it "contain stack trace" do
          subject[0][:subject].should include("Address already in use - bind(2)")
        end

        it "newer(bottom) is first" do
          one = Time.parse(subject[0][:subject])
          two = Time.parse(subject[1][:subject])
          one.should >= two
        end
      end

      context "have 3 errors log includeing sequential 2 error log" do
        let(:logfile) { File.expand_path("./spec/support/fixtures/error3.log", Rails.root) }
        subject { log.recent_errors(3) }

        it "count 3 errors" do
          subject[0][:subject].should include("3 Address already in use - bind(2)")
          subject[0][:notes].size.should be 1
          subject[1][:subject].should include("2 Address already in use - bind(2)")
          subject[1][:notes].size.should be 2
          subject[2][:subject].should include("1 Address already in use - bind(2)")
          subject[2][:notes].size.should be 0
        end
      end
    end
  end

end
