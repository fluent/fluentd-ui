require 'spec_helper'

describe Fluentd::Agent do
  let(:instance) { described_class.new(options) }
  let(:options) {
    {
      :config_file => Rails.root.join('tmp', 'fluentd-test', 'fluentd.conf').to_s
    }
   }

  describe "FluentdGem" do
    let(:described_class) { Fluentd::Agent::FluentdGem } # override nested described_class behavior as https://github.com/rspec/rspec-core/issues/1114

    it_should_behave_like "Fluentd::Agent has common behavior"

    describe "#options_to_argv" do
      subject { instance.send(:options_to_argv) }
      it { should include("-c #{instance.config_file}") }
      it { should include("-d #{instance.pid_file}") }
      it { should include("-o #{instance.log_file}") }
      it { should include("--use-v1-config") }
    end

    describe "#start" do
      before { instance.config_write "" } # ensure valid config
      before { instance.stub(:running?).and_return(running) }

      context "running" do
        let(:running) { true }

        subject { instance.start }

        it { should be_truthy }
      end

      context "not running" do
        let(:running) { false }

        subject { instance.start }

        before do
          instance.stub(:actual_start).and_return(start_result)
        end

        context "actual start success" do
          after do
            FileUtils.rm_r instance.running_config_backup_dir, force: true
          end

          let(:start_result) { true }
          it { should be_truthy }

          it 'backed up running conf' do
            subject
            backup_file = instance.running_config_backup_file
            expect(File.exists? backup_file).to be_truthy
            expect(File.read(backup_file)).to eq File.read(instance.config_file)
          end
        end

        context "actual start failed" do
          let(:start_result) { false }
          it { should be_falsy }
        end
      end
    end

    describe "#stop" do
      before { instance.stub(:running?).and_return(running) }

      subject { instance.stop }

      context "running" do
        let(:running) { true }

        before { instance.stub(:actual_stop).and_return(stop_result) }

        context "actual stop success" do
          let(:stop_result) { true }
          it { should be_truthy }
        end

        context "actual stop failed" do
          let(:stop_result) { false }
          it { should be_falsy }
        end
      end

      context "not running" do
        let(:running) { false }

        it { should be_truthy }
      end
    end

    describe "#restart" do
      it_should_behave_like "Restart strategy"
    end

    describe "#dryrun" do
      describe "valid/invalid" do
        let(:config_path) { Rails.root.join("tmp", "fluent-test.conf").to_s }
        before { File.write(config_path, config) }
        after { File.unlink(config_path) }

        subject { instance.dryrun(config_path) }

        context "valid config" do
          let(:config) { <<-CONF.strip_heredoc }
          <source>
            type forward
          </source>
          CONF

          it { should be_truthy }
        end

        context "invalid config" do
          let(:config) { <<-CONF.strip_heredoc }
          <source>
            type forward
          CONF

          it { should be_falsy }
        end
      end
    end
  end

  describe "TdAgent" do
    let(:described_class) { Fluentd::Agent::TdAgent } # override nested described_class behavior as https://github.com/rspec/rspec-core/issues/1114

    it_should_behave_like "Fluentd::Agent has common behavior"

    describe "#backup_running_config" do
      before do
        instance.stub(:detached_command).and_return(true)
        instance.stub(:pid_from_launchctl).and_return(true)
        instance.config_write "" # ensure valid config
      end

      after do
        FileUtils.rm_r instance.running_config_backup_dir, force: true
      end

      let(:options) do
        {
          :config_file => Rails.root.join('tmp', 'fluentd-test', 'fluentd.conf').to_s
        }
      end

      before do
        instance.start
      end

      it 'backed up running conf' do
        backup_file = instance.running_config_backup_file
        expect(File.exists? backup_file).to be_truthy
        expect(File.read(backup_file)).to eq File.read(instance.config_file)
      end
    end

    describe "#dryrun" do
      subject { instance.dryrun }

      describe "valid/invalid" do
        before { instance.stub(:detached_command).and_return(ret) }

        context "valid config" do
          let(:ret) { true }
          it { should be_truthy }
        end

        context "invalid config" do
          let(:ret) { false }
          it { should be_falsy }
        end
      end

      it "invoke #system" do
        # --dry-run check on Mac, configtest for Unix
        instance.should_receive(:detached_command).with(/(--dry-run|configtest)/)
        subject
      end
    end
  end
end

