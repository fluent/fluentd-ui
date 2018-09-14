class Api::SettingsController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :set_config
  before_action :set_target_element, only: [:show, :update, :destroy]
  helper_method :element_id

  def index
    respond_to do |format|
      format.json
    end
  end

  def update
    coming = Fluent::Config::V1Parser.parse(params[:content], @fluentd.config_file)
    current = @target_element
    index = @config.elements.index current
    unless index
      render_404
      return
    end
    @config.elements[index] = coming.elements.first
    @config.write_to_file
    redirect_to api_setting_path(id: element_id(coming.elements.first))
  end

  def destroy
    if params[:label] == "ROOT"
      name = params[:pluginType]
      arg = params[:arg]
    else
      name = "label"
      arg = params[:label]
    end
    if @config.delete_element(name, arg, @target_element)
      @config.write_to_file
      head :no_content # 204
    else
      render_404
    end
  end

  private

  def set_config
    @config = Fluentd::Setting::Config.new(@fluentd.config_file)
  end

  def set_target_element
    id = params[:id]
    plugin_type = params[:pluginType]
    label_name = params[:label]
    return unless id
    elements = @config.group_by_label.dig(label_name, element_type(plugin_type))
    @target_element = elements.find do |elm|
      element_id(label_name, elm) == id
    end
  end

  def element_id(label_name, element)
    element_type = element_type(element.name)
    elements = @config.group_by_label.dig(label_name, element_type)
    index = elements.index(element)
    "#{"%06d" % index}#{Digest::MD5.hexdigest(element.to_s)}"
  end

  def element_type(name)
    case name
    when "source"
      :sources
    when "filter"
      :filters
    when "match"
      :matches
    end
  end

  def render_404
    render nothing: true, status: 404
  end
end
