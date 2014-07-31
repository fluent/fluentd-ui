class Fluentd::AgentsController < ApplicationController
  before_action :find_fluentd

  def start
    unless @fluentd.agent.start
      flash[:error] = t("messages.fluentd_start_failed", brand: fluentd_ui_title) + @fluentd.agent.log_tail(1).first
    end
    flash[:success] = t("messages.fluentd_start_stop_delay_notice", action: t('fluentd.common.start'))
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def stop
    unless @fluentd.agent.stop
      flash[:error] = t("messages.fluentd_stop_failed", brand: fluentd_ui_title)
    end
    flash[:success] = t("messages.fluentd_start_stop_delay_notice", action: t('fluentd.common.stop'))
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def restart
    unless @fluentd.agent.restart
      flash[:error] = t("messages.fluentd_restart_failed", brand: fluentd_ui_title) + @fluentd.agent.log_tail(1).first
    end
    flash[:success] = t("messages.fluentd_start_stop_delay_notice", action: t('fluentd.common.restart'))
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def log_tail
    @logs = @fluentd.agent.log_tail(params[:limit]).reverse if @fluentd
    render json: @logs
  end
end
