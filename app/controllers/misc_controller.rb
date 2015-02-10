require "fluent/version"
require "zip"

class MiscController < ApplicationController
  after_action :update!, only: [:update_fluentd_ui]

  def show
    redirect_to misc_information_path
  end

  def information
    @env = ENV
    @plugins = Plugin.installed
  end

  def update_fluentd_ui
    @current_pid = $$
    render "update_fluentd_ui", layout: "sign_in"
  end

  def upgrading_status
    if FluentdUiRestart::LOCK.present?
      return render text: "updating"
    end

    if $$.to_s == params[:old_pid]
      # restarting fluentd-ui is finished, but PID doesn't changed.
      # maybe error occured at FluentdUiRestart#perform
      render text: "failed"
    else
      render text: "finished"
    end
  end

  def download_info
    fluentd = Fluentd.instance
    path = Rails.root.join("tmp/system_info.zip")
    File.unlink(path) if File.exists?(path)

    Zip::File.open(path, Zip::File::CREATE) do |zip|
      zip.get_output_stream('fluentd.log') {|f| f.puts fluentd.agent.log.read }
      zip.add("fluentd-ui.log", log_path)

      add_env_file_to(zip)
      add_version_file_to(zip)
    end
    send_file path
  end

  private

  def log_path
    ENV["FLUENTD_UI_LOG_PATH"] || Rails.root.join("log/#{Rails.env}.log")
  end

  def add_env_file_to(zip)
    zip.get_output_stream('env.txt') do |f|
      ENV.to_a.each do |(key, value)|
        f.puts "#{key}=#{value}"
      end
    end
  end

  def add_version_file_to(zip)
    zip.get_output_stream('versions.txt') do |f|
      f.puts "ruby: #{RUBY_DESCRIPTION}"
      f.puts "fluentd: #{FluentdUI.fluentd_version}"
      f.puts "fluentd-ui: #{FluentdUI::VERSION}"
      f.puts
      f.puts "# OS Information"
      f.puts "uname -a: #{`uname -a`.strip}"
    end
  end

  def update!
    FluentdUiRestart.new.async.perform
  end
end
