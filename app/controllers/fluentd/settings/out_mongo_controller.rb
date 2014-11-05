class Fluentd::Settings::OutMongoController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutMongo
  end
end
