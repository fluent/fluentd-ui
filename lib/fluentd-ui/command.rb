require "active_support"
require "active_support/core_ext"

module FluentdUI
  class Command < Thor
    ROOT = File.expand_path('../../../', __FILE__)


    desc "start", "start fluentd-ui server"
    option :port, type: :numeric, default: 9292
    option :pidfile, type: :string, default: File.expand_path('tmp/fluentd-ui.pid', ROOT)
    option :daemonize, type: :boolean, default: false
    option :host, type: :string, default: 'localhost'
    def start
      trap(:INT) { puts "\nStopping..." }
      # NOTE: on Debian based distributions, td-agent uses start-stop-daemon with --exec option for stopping process
      #       then fluentd-ui will be killed by them because given --exec option matches.
      #       FLUENTD_UI_EXEC_COMMAND is used for workaround it.
      cmd = ENV['FLUENTD_UI_EXEC_COMMAND'].presence || "rackup"
      system(* %w(bundle exec) + cmd.split(" ") + %W(#{options[:daemonize] ? "-D" : ""} --pid #{options[:pidfile]} -p #{options[:port]} --host #{options[:host]} -E production #{ROOT}/config.ru))
    end


    desc "stop", "stop fluentd-ui server"
    option :pidfile, type: :string, default: File.expand_path('tmp/fluentd-ui.pid', ROOT)
    def stop
      Process.kill(:TERM, pid) if pid
    rescue Errno::ESRCH
    ensure
      puts "stopped"
    end


    desc "status", "status of fluentd-ui server"
    option :pidfile, type: :string, default: File.expand_path('tmp/fluentd-ui.pid', ROOT)
    def status
      if pid && Process.kill(0, pid)
        puts "fluentd-ui is running"
      else
        puts "fluentd-ui is stopped"
      end
    rescue Errno::ESRCH
      puts "fluentd-ui is stopped"
    end


    desc "setup", "setup fluentd-ui server"
    long_desc <<-DESC
      install dependency gems
    DESC
    def setup
      trap(:INT) { puts "\nStopping..." }
      system(*%W(bundle install))
    end

    private

    def pid
      File.read(options[:pidfile]).to_i rescue nil
    end
  end
end
