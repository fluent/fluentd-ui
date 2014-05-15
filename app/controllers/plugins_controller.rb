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

  def upgrade
    @plugin.upgrade!(@plugin.latest_version)
    redirect_to plugins_path
  end

  private

  def plugins
    # TODO
    [
      Plugin.new(gem_name: "fluent-plugin-mongo", version: "0.7.3"),
      Plugin.new(gem_name: "fluent-plugin-s3"),
      Plugin.new(gem_name: "fluent-plugin-secure-forward", version: "0.1.7"),
    ]
  end

  def find_plugin
    @plugin ||= plugins.find do |plugin|
      plugin.to_param == params[:plugin_id]
    end
  end
end
