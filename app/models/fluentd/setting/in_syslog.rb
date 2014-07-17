class Fluentd
  module Setting
    class InSyslog
      include ActiveModel::Model
      include Common

      KEYS = [
        :port, :bind, :tag, :types
      ].freeze

      attr_accessor(*KEYS)

      validates :tag, presence: true
    end
  end
end
