require "fileutils"
require "json"
require "httpclient"

class Plugin
  class GemError < StandardError; end

  WORKING = []

  include ActiveModel::Model

  attr_accessor :gem_name, :version, :category
  validates :gem_name, presence: true
  validates :version, presence: true

  def to_param
    gem_name
  end

  def install!
    return if installed?

    self.version ||= latest_version
    if valid? && gem_install
      File.open(gemfile_path, "a") do |f|
        f.puts format_gemfile
      end
    end
  end

  def uninstall!
    return unless installed?

    # NOTE: do not uninstall gem actually for now. because it is not necessary, and slow job
    # NOTE: should uninstall that situation: installed verions is A, self.version is NOT A. only check gem_name.
    if gem_uninstall
      new_gemfile = ""
      File.open(gemfile_path).each_line do |line|
        next if line.include?(%Q|gem "#{gem_name}"|)
        new_gemfile << line
      end
      File.open(gemfile_path, "w"){|f| f.write new_gemfile }
    end
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

  def format_gemfile
    self.version ||= latest_version
    %Q|gem "#{gem_name}", "#{version}"|
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

  def rubygems_org_page
    "https://rubygems.org/gems/#{gem_name}"
  end

  def self.gemfile_changed?
    # if true, rails server needs to restart. new installed/removed gems are.
    @initial_gemfile_content != File.read(gemfile_path)
  end

  def self.installed
    return [] unless File.exist?(gemfile_path)
    File.read(gemfile_path).scan(/"(.*?)", "(.*?)"/).map do |plugin|
      new(gem_name: plugin[0], version: plugin[1])
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

  def self.gemfile_path
    Rails.root + "Gemfile.plugins"
  end

  def self.pristine!
    unless File.exists?(gemfile_path)
      File.open(gemfile_path, "w") do |f|
        f.write "# USED BY fluentd-ui internally\n"
      end
    end
    @initial_gemfile_content = File.read(gemfile_path)
  end
  pristine!

  def gemfile_path
    self.class.gemfile_path
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
    fluent_gem("install", gem_name, "-v", version)
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
      unless system(*%W(fluent-gem) + commands) # TODO: should grab stdout/stderr
        raise GemError, "failed command #{commands.join(" ")}"
      end
    end
    true
  end
end
