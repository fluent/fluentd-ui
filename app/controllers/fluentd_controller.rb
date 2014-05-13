class FluentdController < ApplicationController
  before_action :login_required

  def index
    @daemons = [Fluentd.new(Rails.root + "tmp" + "fluentd")] # TODO
  end
end
