class Fluentd < ActiveRecord::Base
  validate :validate_permissions

  def fluentd?
    variant == "fluentd"
  end

  def td_agent?
    variant == "td-agent"
  end

  def start
    agent.start
  end

  def stop
    agent.stop
  end
  
  def reload
    agent.reload
  end

  def running?
    agent.running?
  end

  def log
    # File.read log_file # TODO: large log file
    "log log"
  end

  def agent
    klass = variant.underscore.camelize
    @agent ||= Agent.const_get(klass).new({
      :pid_file => pid_file,
      :log_file => log_file,
      :config_file => config_file,
    })
  end

  def validate_permissions
    %w(pid_file log_file config_file).each do |column|
      path = send(column)
      if File.exist?(path)
        unless File.writable?(path)
          errors.add(column, "#{path} fa")
        end
      else
        unless File.world_writable?(File.dirname(path))
          errors.add(column, "#{path} fa")
        end
      end
    end
  end
end
