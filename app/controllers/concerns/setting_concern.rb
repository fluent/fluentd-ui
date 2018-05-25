module SettingConcern
  extend ActiveSupport::Concern

  included do
    before_action :login_required
    before_action :find_fluentd
    helper_method :target_plugin_name, :plugin_setting_form_action_url
  end


  def show
    @setting = target_class.new(initial_params)
    @_used_param = {}
    @_used_section = {}
    render "shared/settings/show"
  end

  def finish
    @setting = target_class.new(setting_params)
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
    params.require(target_class.to_s.underscore.gsub("/", "_")).permit(*target_plugin_params)
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

  def target_plugin_params
    keys = []
    target_class.config_definition.each do |name, definition|
      if definition[:section]
        keys.concat(parse_section_definition(definition))
      else
        keys.concat(definition.keys)
      end
    end
    keys
  end

  def parse_section_definition(definition)
    keys = []
    definition.except(:section, :argument, :required, :multi, :alias).each do |name, _definition|
      _keys = []
      _definition.each do |key, __definition|
        if __definition[:section]
          _keys.push({ name => parse_section_definition(__definition) })
        else
          _keys.push(key)
        end
      end
      keys.push({ name => _keys })
    end
    keys
  end
end
