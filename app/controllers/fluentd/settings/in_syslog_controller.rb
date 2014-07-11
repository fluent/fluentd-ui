class Fluentd::Settings::InSyslogController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def show
    @setting = Fluentd::Setting::InSyslog.new({
      bind: "0.0.0.0",
      port: 5140,
    })
  end

  def finish
    @setting = Fluentd::Setting::InSyslog.new(setting_params)
    unless @setting.valid?
      return render "show"
    end

    @fluentd.agent.config_append @setting.to_conf
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
    params.require(:fluentd_setting_in_syslog).permit(*Fluentd::Setting::InSyslog::KEYS)
  end

end
