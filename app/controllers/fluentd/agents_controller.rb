class Fluentd::AgentsController < ApplicationController
  before_action :find_fluentd

  def show
  end

  def start
    @fluentd.agent.start
    redirect_to fluentd_agent_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def stop
    @fluentd.agent.stop
    redirect_to fluentd_agent_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def reload
    @fluentd.agent.reload
    redirect_to fluentd_agent_path(@fluentd), status: 303 # 303 is change HTTP Verb GET
  end

  def log
    render text: @fluentd.agent.log, content_type: "text/plain"
  end

  private

  def find_fluentd
    @fluentd = Fluentd.find(params[:fluentd_id])
  end
end
