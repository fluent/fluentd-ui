class Fluentd::Settings::InForwardController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::InForward
  end
end
