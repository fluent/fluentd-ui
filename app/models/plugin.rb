require "fileutils"
require "json"
require "httpclient"

class Plugin
  class GemError < StandardError; end

  include ActiveModel::Model

  attr_accessor :gem_name, :version
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

  private

  def gem_versions
    url = "https://rubygems.org/api/v1/versions/#{gem_name}.json"
    Rails.cache.fetch(url, expires_in: 60.minutes) do  # NOTE: 60.minutes could be changed if it doesn't fit
      res = HTTPClient.get(url)
      res.body if res.code == 200
    end
  end

  def gem_install
    fluent_gem("install", gem_name, "-v", version)
  end

  def gem_uninstall
    fluent_gem("uninstall", gem_name, "-x", "-a")
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
