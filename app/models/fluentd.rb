Bundler.require(:default, :development)

require 'fluent/log'
require 'fluent/env'
require 'fluent/version'
require 'fluent/supervisor'

class Fluentd
  attr_reader :root_dir

  def initialize(root_dir)
    @root_dir = root_dir
    FileUtils.mkdir_p @root_dir
  end

  def pid_file
    File.join(root_dir, "fluentd.pid")
  end

  def pid
    return unless File.exists?(pid_file)
    File.read(pid_file)
  end

  def log_file
    File.join(root_dir, "fluentd.log")
  end

  def config_file
    file = File.join(root_dir, "fluentd.conf")
    unless File.exists?(file)
      File.open(file, "w") {|f| f.write "<source>\ntype forward\n</source>" } # TODO
    end
    file
  end

  def plugin_dir
    dir = File.join(root_dir, "fluentd", "plugins")
    unless Dir.exist?(dir)
      FileUtils.mkdir_p(dir)
    end
    dir
  end

  def options
    # TODO: https://github.com/fluent/fluentd/pull/315
    {
      :config_path => Fluent::DEFAULT_CONFIG_PATH,
      :plugin_dirs => [Fluent::DEFAULT_PLUGIN_DIR],
      :log_level => Fluent::Log::LEVEL_INFO,
      :log_path => nil,
      :daemonize => false,
      :libs => [],
      :setup_path => nil,
      :chuser => nil,
      :chgroup => nil,
      :suppress_interval => 0,
      :suppress_repeated_stacktrace => false,
      :use_v1_config => false,
    }.merge({
      :use_v1_config => true,
      :plugin_dirs => [plugin_dir],
      :config_path => config_file,
      :daemonize => pid_file,
      :log_path => log_file,
      :log_level => Fluent::Log::LEVEL_INFO,
    })
  end

  def running?
    pid && system("/bin/kill -0 #{pid}", :out => File::NULL, :err => File::NULL)
  end

  def start
    return if running?
    spawn("bundle exec fluentd #{options_to_argv(options)}") # TODO
  end

  def stop
    return unless running?
    system("/bin/kill -TERM #{pid}")
    File.unlink(pid_file)
  end

  def reload
    return unless running?
    system("/bin/kill -HUP #{pid}")
  end

  def log
    File.read log_file # TODO: large log file
  end

  def config
    File.read config_file # TODO: Use Fluent::Engine or Fluent::V1Config
  end

  private

  def options_to_argv(options)
    argv = ""
    argv << " --use-v1-config" if options[:use_v1_config]
    argv << " -c #{options[:config_path]}" if options[:config_path].present?
    argv << " -p #{options[:plugin_dir].first}" if options[:plugin_dir].present?
    argv << " -d #{options[:daemonize]}" if options[:daemonize].present?
    argv << " -o #{options[:log_path]}" if options[:log_path].present?
    argv
  end
end
