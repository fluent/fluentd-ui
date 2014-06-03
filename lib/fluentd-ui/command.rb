module FluentdUI
  class Command < Thor
    ROOT = File.expand_path('../../../', __FILE__)


    desc "start", "start fluentd-ui server"
    option :port, type: :numeric, default: 9292
    option :pidfile, type: :string, default: File.expand_path('tmp/fluentd-ui.pid', ROOT)
    option :daemonize, type: :boolean, default: false
    def start
      # NOTE: When fluentd-ui gem updated, it may have new migrations.
      #       do `setup` before `start` solve that, but currently don't. should decide later.
      # setup
      system(*%W(bundle exec rackup #{options[:daemonize] ? "-D" : ""} --pid #{options[:pidfile]} -p #{options[:port]} -E production #{ROOT}/config.ru))
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
      1. install dependency gems

      2. create DB

      3. create initial user if no user registered
    DESC
    def setup
      system(*%W(bundle install))
      system(*%W(bundle exec rake db:create db:migrate db:seed))
    end

    private

    def pid
      File.read(options[:pidfile]).to_i rescue nil
    end
  end
end
