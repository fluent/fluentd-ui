class PluginsController < ApplicationController
  before_action :find_plugin, except: [:index]

  def index
    @plugins = plugins
  end

  def install
    @plugin.install!
    redirect_to plugins_path
  end

  def uninstall
    @plugin.uninstall!
    redirect_to plugins_path
  end

  private

  def plugins
    # TODO
    [
      Plugin.new(gem_name: "fluent-plugin-mongo", version: "0.7.3")
    ]
  end

  def find_plugin
    @plugin ||= plugins.find do |plugin|
      plugin.to_param == params[:plugin_id]
    end
  end
end
