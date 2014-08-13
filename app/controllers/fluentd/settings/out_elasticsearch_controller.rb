class Fluentd::Settings::OutElasticsearchController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::OutElasticsearch
  end

  def initial_params
    {
      host: "127.0.0.1",
      port: 9200,
      index_name: "via_fluentd",
      type_name: "via_fluentd",
      logstash_format: true,
      include_tag_key: false,
      utc_index: true,
    }
  end
end
