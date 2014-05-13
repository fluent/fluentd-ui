class Fluentd::SettingsController < ApplicationController
  before_action :login_required

  def show
    render text: fluentd.config.to_s, content_type: "text/plain"
  end

  private

  def fluentd # TODO
    @fluentd ||= Fluentd.new(Rails.root + "tmp" + "fluentd")
  end
end
