require "fileutils"
require "json"
require "httpclient"

class Plugin
  class GemError < StandardError; end

  WORKING = []

  include ActiveModel::Model
  include Draper::Decoratable

  attr_accessor :gem_name, :version, :category
  validates :gem_name, presence: true
  validates :version, presence: true

  def to_param
    gem_name
  end

  def install!
    return if installed?
    self.version ||= latest_version
    valid? && gem_install
  end

  def uninstall!
    return unless installed?
    gem_uninstall # NOTE: not validate
  end

  def upgrade!(new_version)
    return unless installed?

    upgrade = self.class.new(gem_name: self.gem_name, version: new_version)
    if self.valid? && upgrade.valid?
      self.uninstall!
      upgrade.install!
      self.version = upgrade.version
    end
  end

  def installed?
    self.class.installed.find do |plugin|
      plugin.gem_name == gem_name
    end
  end

  def processing?
    !!WORKING.find{|data| data[:plugin].gem_name == gem_name}
  end

  def installed_version
    return unless inst = installed?
    inst.version
  end

  def latest_version?
    installed_version == latest_version
  end

  def latest_version
    @latest_version ||= JSON.parse(gem_versions).map {|ver| Gem::Version.new ver["number"] }.max.to_s
  end

  def released_versions
    @released_versions ||= JSON.parse(gem_versions).map {|ver| ver["number"]}.sort_by{|ver| Gem::Version.new ver}.reverse
  end

  def summary
    target_version = self.version || latest_version
    JSON.parse(gem_versions).find {|ver| ver["number"] == target_version }.try(:[], "summary")
  end

  def authors
    target_version = self.version || latest_version
    JSON.parse(gem_versions).find {|ver| ver["number"] == target_version }.try(:[], "authors")
  end

  def inspect
    self.version ||= latest_version
    %Q|<#{gem_name}, "#{version}">|
  end

  def rubygems_org_page
    "https://rubygems.org/gems/#{gem_name}"
  end

  def self.installed
    Rails.cache.fetch("installed_gems", expires_in: 3.seconds) do
      Bundler.with_clean_env do
        gems = FluentGem.list
        gems.grep(/fluent-plugin/).map do |gem|
          name, versions_str = gem.strip.split(" ")
          version = versions_str[/[^(), ]+/]
          new(gem_name: name, version: version)
        end
      end
    end
  end

  def self.recommended
    Settings.recommended_plugins.map do |data|
      new(category: data["category"], gem_name: "fluent-plugin-#{data["name"]}")
    end
  end

  def self.processing
    WORKING.find_all do |data|
      data[:state] == :running
    end
  end

  def self.installing
    processing.find_all{|data| data[:type] == :install }.map{|data| data[:plugin] }
  end

  def self.uninstalling
    processing.find_all{|data| data[:type] == :uninstall }.map{|data| data[:plugin] }
  end

  def gem_versions
    Rails.cache.fetch(gem_json_url, expires_in: 60.minutes) do  # NOTE: 60.minutes could be changed if it doesn't fit
      gem_versions!
    end
  end

  def gem_versions!
    res = HTTPClient.get(gem_json_url)
    if res.code == 200
      json = res.body
      Rails.cache.write(gem_json_url, json, expires_in: 60.minutes) # NOTE: 60.minutes could be changed if it doesn't fit
      json
    end
  end

  def gem_json_url
    "https://rubygems.org/api/v1/versions/#{gem_name}.json"
  end

  private

  def gem_install
    data = { plugin: self, state: :running, type: :install }
    return if processing?
    return if installed?
    WORKING.push(data)
    FluentGem.install(gem_name, "--no-ri", "--no-rdoc", "-v", version)
  ensure
    WORKING.delete(data)
  end

  def gem_uninstall
    data = { plugin: self, state: :running, type: :uninstall }
    return if processing?
    return unless installed?
    WORKING.push(data)
    FluentGem.uninstall(gem_name, "-x", "-a")
  ensure
    WORKING.delete(data)
  end
end
