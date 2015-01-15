shared_examples_for "Fluentd::Agent has common behavior" do |klass|
  describe "#extra_options" do
    context "blank" do
      let(:options) { {} }
      it { instance.pid_file.should    == described_class.default_options[:pid_file] }
      it { instance.log_file.should    == described_class.default_options[:log_file] }
      it { instance.config_file.should == described_class.default_options[:config_file] }
    end

    context "given" do
      let(:options) do
        {
          :pid_file => pid_file,
          :log_file => log_file,
          :config_file => config_file,
        }
      end
      let(:pid_file) { "pid" }
      let(:log_file) { "log" }
      let(:config_file) { "config" }

      it { instance.pid_file.should == pid_file }
      it { instance.log_file.should == log_file }
      it { instance.config_file.should == config_file }
    end
  end

  describe "#logged_errors" do
    before { instance.stub(:log_file).and_return(logfile) }

    describe "#errors_since" do
      let(:logged_time) { Time.parse('2014-05-27') }
      let(:now) { Time.parse('2014-05-29') }

      before { Timecop.freeze(now) }
      after { Timecop.return }

      subject { instance.errors_since(days.days.ago) }

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
        subject { instance.recent_errors(2) }

        it "empty array" do
          should be_empty
        end
      end

      context "have 2 error log" do
        let(:logfile) { File.expand_path("./spec/support/fixtures/error2.log", Rails.root) }
        subject { instance.recent_errors(2) }

        describe "limit" do
          subject { instance.recent_errors(limit).length }

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
        subject { instance.recent_errors(3) }

        it "count 3 errors" do
          subject[0][:subject].should include("Address already in use - bind(2)")
          subject[0][:notes].size.should be 1
          subject[1][:subject].should include("Address already in use - bind(2)")
          subject[1][:notes].size.should be 2
          subject[2][:subject].should include("Address already in use - bind(2)")
          subject[2][:notes].size.should be 0
        end
      end
    end
  end
end

