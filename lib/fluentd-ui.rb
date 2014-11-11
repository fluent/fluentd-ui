module FluentdUI
  def self.latest_version=(version)
    @latest = version
  end

  def self.latest_version
    @latest
  end

  def self.update_available?
    return unless @latest
    latest = Gem::Version.new(@latest)
    current = Gem::Version.new(::FluentdUI::VERSION)
    latest > current
  end

  def self.fluentd_version
    setup_fluentd = Fluentd.instance
    return nil unless setup_fluentd
    setup_fluentd.agent.version
  end

  def self.data_dir
    dir = ENV["FLUENTD_UI_DATA_DIR"].presence || ENV["HOME"] + "/.fluentd-ui/core_data"
    FileUtils.mkdir_p(dir) # ensure directory exists
    dir
  end

  def self.td_agent_ui?
    ENV["FLUENTD_UI_TD_AGENT"].present?
  end

  def self.platform
    case RbConfig::CONFIG['host_os']
    when /darwin|mac os/
      :macosx
    else
      :unix
    end
  end
end
