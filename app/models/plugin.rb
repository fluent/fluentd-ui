require "fileutils"

class Plugin
  class GemError < StandardError; end

  GEMFILE_PLUGIN = Rails.root + "Gemfile.plugins"
  unless File.exists?(GEMFILE_PLUGIN)
    File.open(GEMFILE_PLUGIN, "w") do |f|
      f.write "# USED BY fluentd-ui internally"
    end
  end

  include ActiveModel::Model

  attr_accessor :gem_name, :version
  validates :gem_name, presence: true
  validates :version, presence: true

  def to_param
    gem_name
  end

  def install!
    if valid? && !installed?
      if fluent_gem("install", gem_name, "-v", version)
        File.open(GEMFILE_PLUGIN, "a") do |f|
          f.puts format_gemfile
        end
        self.class.gemfile_updated!
      end
    end
  end

  def uninstall!
    if valid? && installed?
      # NOTE: do not uninstall gem actually for now. because it is not necessary, and slow job
      new_gemfile = ""
      File.open(GEMFILE_PLUGIN).each_line do |line|
        next if line.strip == format_gemfile
        new_gemfile << line
      end
      File.open(GEMFILE_PLUGIN, "w"){|f| f.write new_gemfile }
      self.class.gemfile_updated!
    end
  end

  def upgrade!(new_version)
    if installed?
      upgrade = new(gem_name: self.gem_name, version: new_version)
      if self.valid? && upgrade.valid?
        self.uninstall!
        upgrade.install!
      end
    end
  end

  def installed?
    File.read(GEMFILE_PLUGIN).lines.map(&:strip).grep(format_gemfile).present?
  end

  def format_gemfile
    %Q|gem "#{gem_name}", "#{version}"|
  end

  def fluent_gem(*commands)
    unless system(*%W(bundle exec gem) + commands) # TODO: should grab stdout/stderr
      raise GemError, "failed command #{commands}"
    end
    true
  end

  def self.gemfile_changed?
    # if true, rails server needs to restart
    @gemfile_changed
  end

  def self.gemfile_updated!
    @gemfile_changed = true
  end
end
