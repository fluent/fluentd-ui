class FluentdController < ApplicationController
  before_action :login_required

  def index
    @fluentds = Fluentd.all
  end
end
