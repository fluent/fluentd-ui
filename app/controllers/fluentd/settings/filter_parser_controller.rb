class Fluentd::Settings::FilterParserController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::FilterParser
  end
end
