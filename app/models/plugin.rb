require "fileutils"

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
    if valid? && !installed?
      if fluent_gem("install", gem_name, "-v", version)
        File.open(gemfile, "a") do |f|
          f.puts format_gemfile
        end
      end
    end
  end

  def uninstall!
    if valid? && installed?
      # NOTE: do not uninstall gem actually for now. because it is not necessary, and slow job
      new_gemfile = ""
      File.open(gemfile).each_line do |line|
        next if line.strip == format_gemfile
        new_gemfile << line
      end
      File.open(gemfile, "w"){|f| f.write new_gemfile }
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
    File.read(gemfile).lines.map(&:strip).grep(format_gemfile).present?
  end

  def format_gemfile
    %Q|gem "#{gem_name}", "#{version}"|
  end

  def self.gemfile_changed?
    # if true, rails server needs to restart
    @initial_gemfile_content != File.read(gemfile)
  end

  def self.gemfile
    if Rails.env == "test"
      gemfile = Rails.root + "tmp/Gemfile.plugins"
    else
      gemfile = Rails.root + "Gemfile.plugins"
    end

    unless File.exists?(gemfile)
      File.open(gemfile, "w") do |f|
        f.write "# USED BY fluentd-ui internally\n"
      end
    end
    @initial_gemfile_content ||= File.read(gemfile)
    gemfile
  end


  def gemfile
    self.class.gemfile
  end

  private

  def fluent_gem(*commands)
    unless system(*%W(bundle exec gem) + commands) # TODO: should grab stdout/stderr
      raise GemError, "failed command #{commands}"
    end
    true
  end
end
