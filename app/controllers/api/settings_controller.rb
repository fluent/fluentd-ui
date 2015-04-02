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
    @section = @config.elements.find do |elm|
      element_id(elm) == params[:id]
    end
  end

  def element_id(element)
    index = @config.elements.index(element)
    "#{"%06d" % index}#{Digest::MD5.hexdigest(element.to_s)}"
  end

  def render_404
    render nothing: true, status: 404
  end
end
