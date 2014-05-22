class FluentdController < ApplicationController
  def index
    @fluentds = Fluentd.all
  end
end
