class Fluentd < ActiveRecord::Base
  validate :validate_permissions

  def fluentd?
    variant == "fluentd"
  end

  def td_agent?
    variant == "td-agent"
  end

  def running?
    agent.running?
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
          errors.add(column, :lack_write_permission)
        end
        unless File.readable?(path)
          errors.add(column, :lack_read_permission)
        end
      else
        unless File.world_writable?(File.dirname(path))
          errors.add(column, :lack_write_permission)
        end
      end
    end
  end
end
