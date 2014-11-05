class Fluentd::Settings::InSyslogController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::InSyslog
  end
end
