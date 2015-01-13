class Fluentd
  module Setting
    class OutS3
      include ActiveModel::Model
      include Common

      # TODO: needed some trick or separation for testing
      # TODO: `installed_version` will connect to rubygems.org, so webock will raise exception
      if installed_version("fluent-plugin-s3") >= "0.5.0"
        configure_with_yaml "out_s3-0.5.x.yml"
      else
        configure_with_yaml "out_s3-0.4.x.yml"
      end
    end
  end
end
