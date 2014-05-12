class FluentdController < ApplicationController
  def index
    @daemons = [Fluentd.new(Rails.root + "tmp" + "fluentd")] # TODO
  end
end
