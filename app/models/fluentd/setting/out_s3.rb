class Fluentd
  module Setting
    class OutS3
      include ActiveModel::Model
      include Common

      configure_with_yaml "out_s3-0.4.x.yml"
    end
  end
end
