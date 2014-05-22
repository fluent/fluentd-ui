class Fluentd::DaemonsController < ApplicationController
  before_action :find_fluentd

  def show
  end

  def start
    @fluentd.agent.start
    render :show
  end

  def stop
    @fluentd.agent.stop
    render :show
  end

  def reload
    @fluentd.agent.reload
    render :show
  end

  def log
    render text: @fluentd.agent.log, content_type: "text/plain"
  end

  private

  def find_fluentd
    @fluentd = Fluentd.find(params[:fluentd_id])
  end
end
