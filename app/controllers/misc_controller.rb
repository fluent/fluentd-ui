require "fluent/version"

class MiscController < ApplicationController
  def show
    redirect_to misc_information_path
  end

  def information
    @env = ENV
    @plugins = Plugin.installed
  end

  def update_fluentd_ui
    # TODO: Plugin.new(gem_name: "fluentd-ui").install
    restart_fluentd_ui
    # TODO: return views and polling restart finished
  end

  private

  def restart_fluentd_ui
    if Rails.env.production?
      cmd = %W(#{Rails.root}/bin/fluentd-ui start)
    else
      cmd = %W(bundle exec rails s)
    end
    Bundler.with_clean_env do
      restarter = "#{Rails.root}/bin/fluentd-ui-restart"
      Process.spawn(*[restarter, $$.to_s, *cmd, *ARGV]) && Process.kill(:TERM, $$)
    end
  end
end
