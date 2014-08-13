class Fluentd::Settings::InSyslogController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::InSyslog
  end

  def initial_params
    {
      bind: "0.0.0.0",
      port: 5140,
    }
  end
end
