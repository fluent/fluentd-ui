class PluginsController < ApplicationController
  def index
    redirect_to installed_plugins_path
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
    # TODO: how to manage recommended plugins?
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
      Plugin.new(gem_name: "fluent-plugin-rewrite-tag-filter"),
      Plugin.new(gem_name: "fluent-plugin-td"),
      Plugin.new(gem_name: "fluent-plugin-elasticsearch"),
      Plugin.new(gem_name: "fluent-plugin-datacounter"),
      Plugin.new(gem_name: "fluent-plugin-flowcounter"),
      Plugin.new(gem_name: "fluent-plugin-numeric-counter"),
      Plugin.new(gem_name: "fluent-plugin-record-reformer"),
      Plugin.new(gem_name: "fluent-plugin-pghstore"),
      Plugin.new(gem_name: "fluent-plugin-notifier"),
      Plugin.new(gem_name: "fluent-plugin-mysqlslowquery"),
      Plugin.new(gem_name: "fluent-plugin-boundio"),
      Plugin.new(gem_name: "fluent-plugin-ses"),
      Plugin.new(gem_name: "fluent-plugin-groonga"),
      Plugin.new(gem_name: "fluent-plugin-websocket"),
      Plugin.new(gem_name: "fluent-plugin-pgjson"),
      Plugin.new(gem_name: "fluent-plugin-say"),
      Plugin.new(gem_name: "fluent-plugin-uri_decoder"),
      Plugin.new(gem_name: "fluent-plugin-rds-log"),
      Plugin.new(gem_name: "fluent-plugin-msgpack-rpc"),
      Plugin.new(gem_name: "fluent-plugin-reemit"),
      Plugin.new(gem_name: "fluent-plugin-multiprocess"),
      Plugin.new(gem_name: "fluent-plugin-dbi"),
      Plugin.new(gem_name: "fluent-plugin-serialport"),
      Plugin.new(gem_name: "fluent-plugin-loggly"),
      Plugin.new(gem_name: "fluent-plugin-out-solr"),
      Plugin.new(gem_name: "fluent-plugin-riak"),
      Plugin.new(gem_name: "fluent-plugin-couchbase"),
      Plugin.new(gem_name: "fluent-plugin-unique-counter"),
      Plugin.new(gem_name: "fluent-plugin-flatten-hash"),
      Plugin.new(gem_name: "fluent-plugin-solr"),
      Plugin.new(gem_name: "fluent-plugin-dd"),
      Plugin.new(gem_name: "fluent-plugin-gstore"),
      Plugin.new(gem_name: "fluent-plugin-mongokpi"),
      Plugin.new(gem_name: "fluent-plugin-jsonbucket"),
    ]
  end
end
