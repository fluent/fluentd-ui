class Fluentd::Settings::OutS3Controller < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutS3
  end
end
