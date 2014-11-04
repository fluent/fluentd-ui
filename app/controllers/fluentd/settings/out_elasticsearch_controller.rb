class Fluentd::Settings::OutElasticsearchController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutElasticsearch
  end
end
