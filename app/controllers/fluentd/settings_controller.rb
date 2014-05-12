class Fluentd::SettingsController < ApplicationController
  def show
    render text: fluentd.config.to_s, content_type: "text/plain"
  end

  private

  def fluentd # TODO
    @fluentd ||= Fluentd.new(Rails.root + "tmp" + "fluentd")
  end
end
