class FluentdController < ApplicationController
  before_filter :fluentd

  def index
  end

  def status
  end

  def start
    fluentd.start
    render :status
  end

  def stop
    fluentd.stop
    render :status
  end

  def reload
    fluentd.reload
    render :status
  end

  def log
    render text: fluentd.log, content_type: "text/plain"
  end

  private

  def fluentd
    @fluentd ||= Fluentd.new(Rails.root + "tmp" + "fluentd")
  end
end
