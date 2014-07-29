FactoryGirl.define do
  factory :fluentd do
    dir = Rails.root.join("tmp/fluentd-test").to_s
    FileUtils.mkdir_p(dir)

    variant "fluentd_gem"
    log_file dir + "/fluentd.log"
    pid_file dir + "/fluentd.pid"
    config_file dir + "/fluentd.conf"
  end
end
