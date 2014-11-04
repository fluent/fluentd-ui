class Fluentd::Settings::OutForwardController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutForward
  end

  def setting_params
    params.require(:fluentd_setting_out_forward).permit(*Fluentd::Setting::OutForward::KEYS).merge(
      params.require(:fluentd_setting_out_forward).permit(
        :server => Fluentd::Setting::OutForward::Server::KEYS,
        :secondary => Fluentd::Setting::OutForward::Secondary::KEYS,
      ),
    )
  end
end
