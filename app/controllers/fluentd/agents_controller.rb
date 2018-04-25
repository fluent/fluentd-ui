class Fluentd::AgentsController < ApplicationController
  before_action :find_fluentd

  def start
    run_action(__method__) { @fluentd.agent.log.tail(1).first }
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def stop
    run_action(__method__)
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def restart
    run_action(__method__) { @fluentd.agent.log.tail(1).first }
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def reload
    run_action(__method__) { @fluentd.agent.log.tail(1).first }
    redirect_to daemon_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def log_tail
    @logs = @fluentd.agent.log.tail(params[:limit]).reverse if @fluentd
    render json: @logs
  end

  private
  def run_action(action)
    if @fluentd.agent.public_send(action)
      flash[:success] = t("messages.fluentd_start_stop_delay_notice", action: t("fluentd.common.#{action}"))
    else
      flash[:error] = t("messages.fluentd_#{action}_failed", brand: fluentd_ui_title)
      flash[:error] += yield if block_given?
    end
  end
end
