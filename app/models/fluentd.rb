class Fluentd < ActiveRecord::Base
  before_validation :expand_paths
  validates :variant, inclusion: { in: proc { Fluentd.variants } }
  validates :log_file, presence: true
  validates :pid_file, presence: true
  validates :config_file, presence: true
  validate :validate_permissions

  def self.variants
    %w(fluentd) # TODO:
  end

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

  def expand_paths
    %w(pid_file log_file config_file).each do |column|
      self.send("#{column}=", File.expand_path(send(column)))
    end
  end

  def validate_permissions
    %w(pid_file log_file config_file).each do |column|
      path = send(column)
      next if path.empty? # if empty, presence: true will catch it

      if File.exist?(path)
        if File.directory?(path)
          errors.add(column, :is_a_directory)
        end

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
