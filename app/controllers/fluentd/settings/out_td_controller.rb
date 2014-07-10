class Fluentd::Settings::OutTdController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def show
    @setting = Fluentd::Setting::OutTd.new({
      buffer_type: "file",
      buffer_path: "/var/log/td-agent/buffer/td",
      use_ssl: true,
      auto_create_table: true,
    })
  end

  def finish
    @setting = Fluentd::Setting::OutTd.new(setting_params)
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
    params.require(:fluentd_setting_out_td).permit(*Fluentd::Setting::OutTd::KEYS)
  end

end
