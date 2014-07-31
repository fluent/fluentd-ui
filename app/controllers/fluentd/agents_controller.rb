class Fluentd::AgentsController < ApplicationController
  before_action :find_fluentd

  def start
    if @fluentd.agent.start
      flash[:success] = t("messages.fluentd_start_stop_delay_notice", action: t('fluentd.common.start'))
    else
      flash[:error] = t("messages.fluentd_start_failed", brand: fluentd_ui_title) + @fluentd.agent.log_tail(1).first
    end
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def stop
    if @fluentd.agent.stop
      flash[:success] = t("messages.fluentd_start_stop_delay_notice", action: t('fluentd.common.stop'))
    else
      flash[:error] = t("messages.fluentd_stop_failed", brand: fluentd_ui_title)
    end
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def restart
    if @fluentd.agent.restart
      flash[:success] = t("messages.fluentd_start_stop_delay_notice", action: t('fluentd.common.restart'))
    else
      flash[:error] = t("messages.fluentd_restart_failed", brand: fluentd_ui_title) + @fluentd.agent.log_tail(1).first
    end
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def log_tail
    @logs = @fluentd.agent.log_tail(params[:limit]).reverse if @fluentd
    render json: @logs
  end
end
