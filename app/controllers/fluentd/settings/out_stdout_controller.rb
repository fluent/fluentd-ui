class Fluentd::Settings::OutStdoutController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutStdout
  end
end
