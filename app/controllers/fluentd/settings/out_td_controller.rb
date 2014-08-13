class Fluentd::Settings::OutTdController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutTd
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
