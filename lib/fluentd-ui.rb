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
end
