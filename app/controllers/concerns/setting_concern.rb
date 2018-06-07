module SettingConcern
  extend ActiveSupport::Concern

  included do
    before_action :login_required
    before_action :find_fluentd
    helper_method :target_plugin_name, :plugin_setting_form_action_url
  end


  def show
    @setting = target_class.new(initial_params)
    @parser = @setting.create_parser
    @formatter = @setting.create_formatter
    @_used_param = {}
    @_used_section = {}
    render "shared/settings/show"
  end

  def configure
    owned_keys = %i(parse_type format_type)
    @setting = target_class.new(initial_params.merge(params.permit(*owned_keys).slice(*owned_keys)))
    @parser = @setting.create_parser
    @formatter = @setting.create_formatter
    render "shared/settings/show"
  end

  def finish
    @setting = target_class.new(setting_params)
    @_used_param = {}
    @_used_section = {}
    unless @setting.valid?
      return render "shared/settings/show"
    end

    @fluentd.agent.config_append @setting.to_config
    if @fluentd.agent.running?
      unless @fluentd.agent.restart
        @setting.errors.add(:base, @fluentd.agent.log.tail(1).first)
        return render "shared/settings/show"
      end
    end
    redirect_to daemon_setting_path(@fluentd)
  end

  private

  def setting_params
    params.require(target_class.to_s.underscore.gsub("/", "_")).permit(*target_class.permit_params)
  end

  def initial_params
    target_class.initial_params
  end

  def target_plugin_name
    prefix = case target_class.plugin_type
             when "input"
               "in"
             when "output"
               "out"
             else
               target_class.plugin_type
             end
    "#{prefix}_#{target_class.plugin_name}"
  end

  def plugin_setting_form_action_url(*args)
    send("finish_daemon_setting_#{target_plugin_name}_path", *args)
  end
end
