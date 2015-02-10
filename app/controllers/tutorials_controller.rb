class TutorialsController < ApplicationController
  before_action :find_fluentd
  before_action :check_ready, only: [:chapter1, :chapter2]
  before_action :set_in_http, only: [:chapter1, :chapter2, :request_fluentd]
  helper_method :tutorial_ready?

  def index
    @log = @fluentd.agent.log.tail.reverse if @fluentd
  end

  def chapter1
  end

  def chapter2
    @default_conf = Fluentd::DEFAULT_CONF
  end

  def request_fluentd
    HTTPClient.post("http://localhost:#{@in_http["port"]}#{params[:path]}", json: params[:data].to_json)
    render nothing: true, status: 204
  end

  private

  def set_in_http
    @in_http = @fluentd.agent.configuration.sources.find{|directive| directive["type"] == "http"}
  end

  def find_fluentd
    @fluentd = Fluentd.instance
  end

  def check_ready
    redirect_to tutorials_url unless tutorial_ready?
  end

  def tutorial_ready?
    @fluentd && @fluentd.agent.running?
  end
end
