class Fluentd::Settings::InTailController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def after_file_choose
    @setting = Fluentd::Setting::InTail.new({
      path: params[:path],
      tag: nil
    })
  end

  def after_format
    # NOTE: pos_file form field doesn't exists before this action
    attrs = setting_params
    if attrs[:pos_file].blank?
      attrs.merge!(pos_file: "/tmp/fluentd-#{@fluentd.id}-#{Time.now.to_i}.pos")
    end
    @setting = Fluentd::Setting::InTail.new(attrs)
  end

  def confirm
    @setting = Fluentd::Setting::InTail.new(setting_params)
    if params[:back]
      return render :after_file_choose
    end
    unless @setting.valid?
      return render :after_format
    end
  end

  def finish
    @setting = Fluentd::Setting::InTail.new(setting_params)
    if params[:back]
      return render :after_format
    end

    unless @setting.valid?
      return render "after_format"
    end

    if @fluentd.agent.configuration.to_s.include?(@setting.to_config.to_s.strip)
      @setting.errors.add(:base, :duplicated_conf)
      return render "after_format"
    end

    @fluentd.agent.config_append @setting.to_config.to_s
    @fluentd.agent.restart if @fluentd.agent.running?
    redirect_to daemon_setting_path(@fluentd)
  end

  def target_class
    Fluentd::Setting::InTail
  end

  private

  def setting_params
    permit_params = target_class._types.keys
    permit_params << :parse_type
    section_class = Fluentd::Setting.const_get("parser_#{params.dig(:setting, :parse_type)}".classify)
    permit_params << { parse: section_class._types.keys }
    params.require(:setting).permit(*permit_params)
  end

end
