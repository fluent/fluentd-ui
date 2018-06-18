class Fluentd::Settings::OutTdlogController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutTdlog
  end
end
