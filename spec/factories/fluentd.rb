FactoryGirl.define do
  factory :fluentd do
    variant "fluentd_gem"
    log_file (Rails.root + "tmp/fluentd-test/fluentd.log").to_s
    pid_file (Rails.root + "tmp/fluentd-test/fluentd.pid").to_s
    config_file (Rails.root + "tmp/fluentd-test/fluentd.conf").to_s
  end
end
