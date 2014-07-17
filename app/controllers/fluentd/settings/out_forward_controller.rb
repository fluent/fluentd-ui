class Fluentd::Settings::OutForwardController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def show
    @setting = Fluentd::Setting::OutForward.new({
    })
  end

  def finish
    @setting = Fluentd::Setting::OutForward.new(setting_params)
    unless @setting.valid?
      return render "show"
    end

    @fluentd.agent.config_append @setting.to_config
    if @fluentd.agent.running?
      unless @fluentd.agent.restart
        @setting.errors.add(:base, @fluentd.agent.log_tail(1).first)
        return render "show"
      end
    end
    redirect_to fluentd_setting_path(@fluentd)
  end

  private

  def setting_params
    params.require(:fluentd_setting_out_forward).permit(*Fluentd::Setting::OutForward::KEYS).merge(
      params.require(:fluentd_setting_out_forward).permit(:server => Fluentd::Setting::OutForward::Server::KEYS)
    )
  end

end
