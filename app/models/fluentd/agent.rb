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
    #   - https://github.com/treasure-data/td-agent/blob/master/td-agent.logrotate#L10
    #   - https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.init#L25
    #   fluentd:  nothing (or --daemon PIDFILE)
    #
    # logfile
    #   td-agent: /var/log/td-agent/td-agent.log
    #   - https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.init#L28
    #   fluentd: stdout (or --log LOGFILE)
    #
    # config file
    #   td-agent: /etc/td-agent/td-agent.conf
    #   - https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.postinst#L69
    #   fluentd: /etc/fluent/fluent.conf (by fluentd -s)
  end
end
