require 'spec_helper'

describe MiscController do
  let(:instance) { Fluentd.new(id: nil, variant: "fluentd_gem", log_file: "dummy.log", pid_file: "dummy.pid", config_file: "dummy.conf") }

  class DummyAagent
    def log
      "dummy_log_content"
    end

    def version
      "dummy version"
    end
  end

  let!(:dummy_agent) { DummyAagent.new }
  let!(:fluentd_log_content) { dummy_agent.log }
  let!(:fluentd_version) { dummy_agent.version }
  let(:fluentd_ui_log_content) { <<-LOG.strip_heredoc }
    log1
    log2
    log3
  LOG

  let!(:dummy_log_path) { "tmp/dummy.log" }
  let!(:expand_dir) { Rails.root.join("tmp/system_info") }

  before do
    allow(controller).to receive(:current_user).and_return true

    #dummy log for fluentd-ui.log
    File.open(dummy_log_path, 'w') { |file| file.write(fluentd_ui_log_content) }
    controller.stub(:log_path) { dummy_log_path }

    instance.stub(:agent).and_return(dummy_agent)
    Fluentd.stub(:instance).and_return(instance)
  end

  describe 'download_info' do
    before do
      get 'download_info'

      #expand files in zip
      Zip::File.open(Rails.root.join("tmp/system_info.zip")) do |zip_file|
        FileUtils.mkdir_p(expand_dir)

        zip_file.each do |f|
          f_path = File.join(expand_dir, f.name)
          zip_file.extract(f, f_path) unless File.exist?(f_path)
        end
      end
    end

    #remove all temp files for this spec
    after do
      FileUtils.rm Rails.root.join("tmp/system_info.zip")
      FileUtils.rm_r expand_dir
      FileUtils.rm dummy_log_path
    end

    it 'write files' do
      expect(File.read(File.join(expand_dir, "fluentd.log"))).to eq "#{fluentd_log_content}\n"
      expect(File.read(File.join(expand_dir, "fluentd-ui.log"))).to eq "#{fluentd_ui_log_content}"
      expect(File.read(File.join(expand_dir, "env.txt"))).to match "RAILS_ENV=test"
      expect(File.read(File.join(expand_dir, "versions.txt"))).to match "fluentd: #{fluentd_version}"
    end
  end
end
