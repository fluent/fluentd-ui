class Fluentd::Settings::InMonitorAgentController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::InMonitorAgent
  end
end
