class Api::ConfigDefinitionsController < ApplicationController
  before_action :login_required

  def index
    name = params[:name]
    type = params[:type]
    prefix = case type
             when "input"
               "in"
             when "output"
               "out"
             when "filter"
               "filter"
             when "parse"
               "parser"
             when "format"
               "formatter"
             when "parser", "formatter", "buffer", "storage"
               type
             end

    target_class = Fluentd::Setting.const_get("#{prefix}_#{name}".classify)
    target = target_class.new

    common_options = build_options(target, target.common_options)
    advanced_options = build_options(target, target.advanced_options)

    options = {
      type: type,
      name: name,
      commonOptions: common_options,
      advancedOptions: advanced_options
    }

    if type == "input" && ["forward", "syslog"].include?(name)
      transport = target.class._sections[:transport]
      transport_common_options = build_options(transport, target.transport_common_options)
      transport_advanced_options = build_options(transport, target.transport_advanced_options)
      options[:transport] = {
        commonOptions: transport_common_options,
        advancedOptions: transport_advanced_options
      }
    end

    if type == "output" && name == "forward"
      tls_options = build_options(target, target.tls_options)
      options[:tlsOptions] = tls_options
    end

    render json: options
  end

  private

  def build_options(target, keys)
    keys.map do |key|
      h = {
        name: key,
        type: target.column_type(key),
        desc: target.desc(key),
        default: target.default(key)
      }
      h[:list] = target.list_of(key) if target.column_type(key) == :enum
      h
    end
  end
end
