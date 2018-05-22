require 'fluent/log'
require 'fluent/env'
require 'fluent/version'
require 'fluent/supervisor'
require "fluentd/agent/common"
require "fluentd/agent/fluentd_gem"
require "fluentd/agent/td_agent"

class Fluentd
  class Agent
    # pidfile
    #   td-agent: /var/run/td-agent/td-agent.pid
    #   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L18
    #   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/deb/td-agent#L24
    #   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/rpm/td-agent#L24
    #   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/td-agent/logrotate.d/td-agent.logrotate#L10
    #   fluentd:  nothing (or --daemon PIDFILE)
    #
    # logfile
    #   td-agent: /var/log/td-agent/td-agent.log
    #   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L21
    #   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/deb/td-agent#L23
    #   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/rpm/td-agent#L23
    #   fluentd: stdout (or --log LOGFILE)
    #
    # config file
    #   td-agent: /etc/td-agent/td-agent.conf
    #   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L14
    #   fluentd: /etc/fluent/fluent.conf (created by fluentd -s)
    class ConfigError < StandardError; end
  end
end
