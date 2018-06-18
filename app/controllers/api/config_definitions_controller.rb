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

    common_options = target.common_options.map do |key|
      h = {
        name: key,
        type: target.column_type(key),
        desc: target.desc(key),
        default: target.default(key)
      }
      h[:list] = target.list_of(key) if target.column_type(key) == :enum
      h
    end

    advanced_options = target.advanced_options.map do |key|
      h = {
        name: key,
        type: target.column_type(key),
        desc: target.desc(key),
        default: target.default(key)
      }
      h[:list] = target.list_of(key) if target.column_type(key) == :enum
      h
    end

    options = {
      type: type,
      name: name,
      commonOptions: common_options,
      advancedOptions: advanced_options
    }
    render json: options
  end
end
