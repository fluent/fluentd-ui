class Fluentd::Settings::OutS3Controller < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutS3
  end

  def setting_params
    params.require(:fluentd_setting_out_s3).permit(*Fluentd::Setting::OutS3::KEYS)
  end

end
