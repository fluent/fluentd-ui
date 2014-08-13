class Fluentd::Settings::OutMongoController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutMongo
  end

  def initial_params
    {
      host: "127.0.0.1",
      port: 27017,
      capped: true,
      capped_size: "100m",
    }
  end
end
