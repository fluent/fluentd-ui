class Fluentd::AgentsController < ApplicationController
  before_action :find_fluentd

  def show
    @error_count = 10
    @errors = @fluentd.agent.recent_errors(@error_count)
  end

  def start
    unless @fluentd.agent.start
      flash[:error] = t("error.fluentd_start_failed")
    end
    redirect_to fluentd_agent_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def stop
    unless @fluentd.agent.stop
      flash[:error] = t("error.fluentd_stop_failed")
    end
    redirect_to fluentd_agent_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def restart
    unless @fluentd.agent.restart
      flash[:error] = t("error.fluentd_restart_failed")
    end
    redirect_to fluentd_agent_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def log
    render text: @fluentd.agent.log, content_type: "text/plain"
  end
end
