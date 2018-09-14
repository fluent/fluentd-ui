class Api::SettingsController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :set_config
  before_action :set_section, only: [:show, :update, :destroy]
  helper_method :element_id

  def index
    respond_to do |format|
      format.json
    end
  end

  def update
    coming = Fluent::Config::V1Parser.parse(params[:content], @fluentd.config_file)
    current = @section
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
    unless @config.elements.index(@section)
      render_404
      return
    end
    @config.elements.delete @section
    @config.write_to_file
    head :no_content # 204
  end

  private

  def set_config
    @config = Fluentd::Setting::Config.new(@fluentd.config_file)
  end

  def set_section
    id = params[:id]
    return unless id
    label_name = id.slice(/\A(sources|filters|matches):.+/)[1]
    elements = @config.group_by_label.dig(label_name, element_type)
    @section = elements.find do |elm|
      element_id(elm) == id
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
