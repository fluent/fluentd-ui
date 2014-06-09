class TutorialsController < ApplicationController
  before_action :find_fluentd
  before_action :check_ready, only: [:chapter1, :chapter2]
  helper_method :tutorial_ready?

  def index
    @log = @fluentd.agent.log_tail.reverse if @fluentd
  end

  def chapter1
  end

  def chapter2
    @default_conf = Fluentd::DEFAULT_CONF
  end

  def log_tail
    @logs = @fluentd.agent.log_tail.reverse if @fluentd
    render json: @logs
  end

  def request_fluentd
    HTTPClient.post("http://localhost:9880#{params[:path]}", json: params[:data].to_json)
    render nothing: true, status: 204
  end

  private

  def find_fluentd
    # NOTE: use first fluentd for tutorial
    @fluentd = Fluentd.first
  end

  def check_ready
    return redirect_to tutorials_url unless tutorial_ready?
  end

  def tutorial_ready?
    @fluentd && @fluentd.agent.running?
  end
end
