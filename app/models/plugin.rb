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
        fluent_gem = fluent_gem_path
        return [] unless fluent_gem
        gems = `#{fluent_gem} list`.try(:lines)
        return [] unless gems
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

  def self.fluent_gem_path
    # On installed both td-agent and fluentd system, decide which fluent-gem command should be used depend on setup(Fluentd.instance)
    if Fluentd.instance && Fluentd.instance.fluentd?
      return "fluent-gem" # maybe `fluent-gem` command is in the $PATH
    end

    # NOTE: td-agent has a command under the /usr/lib{,64}, td-agent2 has under /opt/td-agent
    %W(
      /usr/sbin/td-agent-gem
      /opt/td-agent/embedded/bin/fluent-gem
      /usr/lib/fluent/ruby/bin/fluent-gem
      /usr/lib64/fluent/ruby/bin/fluent-gem
      fluent-gem
    ).find do |path|
      system("which #{path}", out: File::NULL, err: File::NULL)
    end
  end

  private

  def gem_install
    data = { plugin: self, state: :running, type: :install }
    return if processing?
    return if installed?
    WORKING.push(data)
    fluent_gem("install", gem_name, "--no-document", "-v", version)
  ensure
    WORKING.delete(data)
  end

  def gem_uninstall
    data = { plugin: self, state: :running, type: :uninstall }
    return if processing?
    return unless installed?
    WORKING.push(data)
    fluent_gem("uninstall", gem_name, "-x", "-a")
  ensure
    WORKING.delete(data)
  end

  def fluent_gem(*commands)
    # NOTE: use `fluent-gem` instead of `gem`
    Bundler.with_clean_env do
      # NOTE: this app is under the Bundler, so call `system` in with_clean_env is Bundler jail breaking
      unless system(* [fluent_gem_path, *commands])
        raise GemError, "failed command #{commands.join(" ")}"
      end
    end
    true
  end

  def fluent_gem_path
    self.class.fluent_gem_path
  end
end
