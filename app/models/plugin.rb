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
    unless installed?
      self.version = latest_version unless version
      if valid?
        if fluent_gem("install", gem_name, "-v", version)
          File.open(gemfile_path, "a") do |f|
            f.puts format_gemfile
          end
        end
      end
    end
  end

  def uninstall!
    if installed?
      # NOTE: do not uninstall gem actually for now. because it is not necessary, and slow job
      # NOTE: should uninstall that situation: installed verions is A, self.version is NOT A.
      new_gemfile = ""
      File.open(gemfile_path).each_line do |line|
        next if line.include?(%Q|gem "#{gem_name}"|)
        new_gemfile << line
      end
      File.open(gemfile_path, "w"){|f| f.write new_gemfile }
    end
  end

  def upgrade!(new_version)
    if installed?
      upgrade = self.class.new(gem_name: self.gem_name, version: new_version)
      if self.valid? && upgrade.valid?
        self.uninstall!
        upgrade.install!
      end
    end
  end

  def installed?
    self.class.installed.find do |plugin|
      plugin.gem_name == gem_name
    end
  end

  def format_gemfile
    self.version = latest_version unless version
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
    @latest_version ||=
      begin
        url = "https://rubygems.org/api/v1/versions/#{gem_name}.json"
        Rails.cache.fetch(url, expires_in: 10.minutes) do  # NOTE: 10.minutes could be changed if it doesn't fit
          res = HTTPClient.get(url)
          if res.code == 200
            JSON.parse(res.body).map {|ver| Gem::Version.new ver["number"] }.max.to_s
          end
        end
      end
  end

  def self.gemfile_changed?
    # if true, rails server needs to restart }
    @initial_gemfile_content != File.read(gemfile_path)
  end

  def self.installed
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

  def fluent_gem(*commands)
    unless system(*%W(bundle exec fluent-gem) + commands) # TODO: should grab stdout/stderr
      raise GemError, "failed command #{commands.join(" ")}"
    end
    true
  end
end
