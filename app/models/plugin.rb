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
