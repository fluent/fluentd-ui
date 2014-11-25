class Api::SettingsController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :set_config
  before_action :set_section, only: [:show, :update, :destroy]
  helper_method :element_id
  respond_to :json

  def index
  end

  def update
    coming = Fluent::Config::V1Parser.parse(params[:body], @fluentd.config_file)
    current = @section
    index = @config.elements.index current
    @config.elements[index] = coming.elements.first
    @config.write_to_file
    head :no_content # 204
  end

  def destroy
    @config.elements.delete @section
    @config.write_to_file
    head :no_content # 204
  end

  private

  def set_config
    # TODO: not found
    @config = Fluentd::Setting::Config.new(@fluentd.config_file)
  end

  def set_section
    # TODO: not found
    @section = @config.elements.find do |elm|
      element_id(elm) == params[:id]
    end
  end

  def element_id(element)
    index = @config.elements.index(element) # TODO: not found
    "#{"%06d" % index}#{Digest::MD5.hexdigest(element.to_s)}"
  end
end
