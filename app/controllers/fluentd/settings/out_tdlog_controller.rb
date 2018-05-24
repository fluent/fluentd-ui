class Fluentd::Settings::OutTdlogController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutTdlog
  end

  def initial_params
    {
      buffer_type: "file",
      buffer_path: "/var/log/td-agent/buffer/td",
      auto_create_table: true,
      match: "td.*.*",
    }
  end
end
