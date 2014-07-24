class Fluentd::AgentsController < ApplicationController
  before_action :find_fluentd

  def start
    unless @fluentd.agent.start
      flash[:error] = t("error.fluentd_start_failed") + @fluentd.agent.log_tail(1).first
    end
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def stop
    unless @fluentd.agent.stop
      flash[:error] = t("error.fluentd_stop_failed")
    end
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def restart
    unless @fluentd.agent.restart
      flash[:error] = t("error.fluentd_restart_failed") + @fluentd.agent.log_tail(1).first
    end
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def log_tail
    @logs = @fluentd.agent.log_tail(params[:limit]).reverse if @fluentd
    render json: @logs
  end
end
