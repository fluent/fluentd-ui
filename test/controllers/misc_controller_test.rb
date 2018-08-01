require "test_helper"

class MiscControllerTest < ActionDispatch::IntegrationTest
  class DummyAgent
    def log
      Struct.new(:read).new(read: "dummy_log_content")
    end

    def version
      "dummy version"
    end
  end

  setup do
    @fluentd = FactoryBot.build(:fluentd, log_file: "dummy.log")
    @agent = DummyAgent.new
    @fluentd_log_content = @agent.log.read
    @fluentd_version = @agent.version
    @fluentd_ui_log_content = <<-LOG.strip_heredoc
    log1
    log2
    log3
    LOG

    @dummy_log_path = "tmp/dummy.log"
    @destination_dir = Rails.root.join("tmp/system_info")

    user = FactoryBot.build(:user)
    post(sessions_path(session: { name: user.name, password: user.password }))
    any_instance_of(MiscController) do |object|
      stub(object).log_path { @dummy_log_path }
    end

    File.write(@dummy_log_path, @fluentd_ui_log_content)
    stub(@fluentd).agent { @agent }
    stub(Fluentd).instance { @fluentd }
  end

  sub_test_case "download info" do
    setup do
      get(misc_download_info_path)
      #expand files in zip
      Zip::File.open(Rails.root.join("tmp/system_info.zip")) do |zip_file|
        FileUtils.mkdir_p(@destination_dir)

        zip_file.each do |entry|
          destination = File.join(@destination_dir, entry.name)
          zip_file.extract(entry, destination) unless File.exist?(destination)
        end
      end
    end

    teardown do
      FileUtils.rm_rf(Rails.root.join("tmp/system_info.zip"))
      FileUtils.rm_rf(@destination_dir)
      FileUtils.rm_rf("tmp/dummy.log")
    end

    def content_of(name)
      File.read(File.join(@destination_dir, name))
    end

    test "write files" do
      assert_equal("#{@fluentd_log_content}\n", content_of("fluentd.log"))
      assert_equal("#{@fluentd_ui_log_content}", content_of("fluentd-ui.log"))
      assert_match("RAILS_ENV=test", content_of("env.txt"))
      assert_match("fluentd: #{@fluentd_version}", content_of("versions.txt"))
    end
  end
end
