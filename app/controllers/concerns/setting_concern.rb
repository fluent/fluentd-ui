module SettingConcern
  extend ActiveSupport::Concern

  included do
    before_action :login_required
    before_action :find_fluentd
  end

  def show
    @setting = target_class.new(initial_params)
  end

  def finish
    @setting = target_class.new(setting_params)
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
    redirect_to daemon_setting_path(@fluentd)
  end

  private

  def setting_params
    params.require(target_class.to_s.underscore.gsub("/", "_")).permit(*target_class.const_get(:KEYS))
  end
end
