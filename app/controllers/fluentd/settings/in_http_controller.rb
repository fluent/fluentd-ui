class Fluentd::Settings::InHttpController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::InHttp
  end
end
