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
        File.open(gemfile_path, "a") do |f|
          f.puts format_gemfile
        end
      end
    end
  end

  def uninstall!
    if valid? && installed?
      # NOTE: do not uninstall gem actually for now. because it is not necessary, and slow job
      new_gemfile = ""
      File.open(gemfile_path).each_line do |line|
        next if line.strip == format_gemfile
        new_gemfile << line
      end
      File.open(gemfile_path, "w"){|f| f.write new_gemfile }
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
    File.read(gemfile_path).lines.map(&:strip).grep(format_gemfile).present?
  end

  def format_gemfile
    %Q|gem "#{gem_name}", "#{version}"|
  end

  def self.gemfile_changed?
    # if true, rails server needs to restart }
    @initial_gemfile_content != File.read(gemfile_path)
  end

  def self.gemfile_path
    if Rails.env == "test"
      gemfile_path = "/tmp/fluentd-ui-test-Gemfile.plugins" # can't create a file under Rails.root directory on Circle CI
    else
      gemfile_path = Rails.root + "Gemfile.plugins"
    end
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
      raise GemError, "failed command #{commands}"
    end
    true
  end
end
