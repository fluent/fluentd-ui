class TutorialsController < ApplicationController
  before_action :find_fluentd

  def index
    @log = @fluentd.agent.log_tail.reverse if @fluentd
  end

  private

  def find_fluentd
    # NOTE: use first fluentd for tutorial
    @fluentd = Fluentd.first
  end
end
