class PluginsController < ApplicationController
  def index
    redirect_to updated_plugins_path
  end

  def installed
    @plugins = Plugin.installed
  end

  def recommended
    @plugins = recommended_plugins
  end

  def updated
    @plugins = Plugin.installed.reject{|plugin| plugin.latest_version? }
  end

  def install
    params[:plugins].each do |gem_name|
      GemInstaller.new.async.perform(gem_name)
    end
    redirect_to plugins_path
  end

  def uninstall
    params[:plugins].each do |gem_name|
      GemUninstaller.new.async.perform(gem_name)
    end
    redirect_to plugins_path
  end

  def upgrade
    GemInstaller.new.async.perform(params[:plugins][:name], params[:plugins][:version])
    redirect_to plugins_path
  end

  private

  def recommended_plugins
    # TODO
    [
      Plugin.new(gem_name: "fluent-plugin-mongo"),
      Plugin.new(gem_name: "fluent-plugin-s3"),
      Plugin.new(gem_name: "fluent-plugin-secure-forward"),
      Plugin.new(gem_name: "fluent-plugin-forest"),
      Plugin.new(gem_name: "fluent-plugin-couch"),
      Plugin.new(gem_name: "fluent-plugin-dstat"),
      Plugin.new(gem_name: "fluent-plugin-parser"),
      Plugin.new(gem_name: "fluent-plugin-map"),
      Plugin.new(gem_name: "fluent-plugin-grep"),
      Plugin.new(gem_name: "fluent-plugin-webhdfs"),
    ]
  end
end
