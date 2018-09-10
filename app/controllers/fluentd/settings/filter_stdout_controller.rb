class Fluentd::Settings::FilterStdoutController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::FilterStdout
  end
end
