class Fluentd::DaemonsController < ApplicationController
  before_action :login_required
  before_action :fluentd

  def show
  end

  def start
    fluentd.start
    render :show
  end

  def stop
    fluentd.stop
    render :show
  end

  def reload
    fluentd.reload
    render :show
  end

  def log
    render text: fluentd.log, content_type: "text/plain"
  end

  private

  def fluentd
    @fluentd = Fluentd.find(params[:fluentd_id])
  end
end
