class PluginsController < ApplicationController
  helper_method :plugins_json

  def index
    redirect_to installed_plugins_path
  end

  def installed
    @plugins = PluginDecorator.decorate_collection(Plugin.installed.reject{|plugin| plugin.processing? })
  end

  def recommended
    @plugins = PluginDecorator.decorate_collection(Plugin.recommended)
  end

  def updated
    @plugins = PluginDecorator.decorate_collection(Plugin.installed.reject{|plugin| plugin.latest_version? })
  end

  def install
    params[:plugins].each do |gem_name|
      GemInstallerJob.perform_later(gem_name)
    end
    respond_to do |format|
      format.html do
        redirect_to plugins_path
      end
      format.json do
        plugins = PluginDecorator.decorate_collection(Plugin.recommended.select {|item| params[:plugins].include?(item.gem_name)})
        render json: plugins.map(&:to_hash).to_json
      end
    end

  end

  def uninstall
    params[:plugins].each do |gem_name|
      GemUninstallerJob.perform_later(gem_name)
    end
    redirect_to plugins_path
  end

  def upgrade
    GemInstallerJob.perform_later(params[:plugins][:name], params[:plugins][:version])
    redirect_to plugins_path
  end

  def bulk_upgrade
    params[:plugins].each do |gem_name|
      pl = Plugin.new(gem_name: gem_name)
      GemInstallerJob.perform_later(gem_name, pl.latest_version)
    end
    redirect_to plugins_path
  end

  private

  def plugins_json
    JSON.pretty_generate(@plugins.map(&:to_hash))
  end
end
