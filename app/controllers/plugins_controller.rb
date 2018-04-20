class PluginsController < ApplicationController
  def index
    redirect_to installed_plugins_path
  end

  def installed
    @plugins = Plugin.installed.reject{|plugin| plugin.processing? }
  end

  def recommended
    @plugins = PluginDecorator.decorate_collection(Plugin.recommended)
  end

  def updated
    @plugins = Plugin.installed.reject{|plugin| plugin.latest_version? }
  end

  def install
    params[:plugins].each do |gem_name|
      GemInstallerJob.perform_later(gem_name)
    end
    redirect_to plugins_path
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
end
