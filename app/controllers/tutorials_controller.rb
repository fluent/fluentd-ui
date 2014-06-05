class TutorialsController < ApplicationController
  before_action :find_fluentd
  helper_method :tutorial_ready?

  def index
    @log = @fluentd.agent.log_tail.reverse if @fluentd
  end

  def chapter1
    return redirect_to tutorials_url unless tutorial_ready?
  end

  def log_tail
    @logs = @fluentd.agent.log_tail.reverse if @fluentd
    render json: @logs
  end

  def request_fluentd
    HTTPClient.post("http://localhost:8888#{params[:path]}", json: params[:data].to_json)
    render nothing: true, status: 204
  end

  private

  def find_fluentd
    # NOTE: use first fluentd for tutorial
    @fluentd = Fluentd.first
  end

  def tutorial_ready?
    @fluentd && @fluentd.agent.running?
  end
end
