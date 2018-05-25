class Fluentd::Settings::OutForwardController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutForward
  end
end
