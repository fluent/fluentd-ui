class Fluentd::Settings::OutMongoController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def show
    @setting = Fluentd::Setting::OutMongo.new({
      host: "127.0.0.1",
      port: 27017,
      capped: true,
      capped_size: "100m",
    })
  end

  def finish
    @setting = Fluentd::Setting::OutMongo.new(setting_params)
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
    params.require(:fluentd_setting_out_mongo).permit(*Fluentd::Setting::OutMongo::KEYS)
  end

end
