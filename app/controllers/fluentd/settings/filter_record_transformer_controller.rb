class Fluentd::Settings::FilterRecordTransformerController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::FilterRecordTransformer
  end
end
