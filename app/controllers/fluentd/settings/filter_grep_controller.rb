class Fluentd::Settings::FilterGrepController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::FilterGrep
  end
end
