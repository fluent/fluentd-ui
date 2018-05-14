class Fluentd
  module Setting
    module Pattern
      extend ActiveSupport::Concern

      included do
        config_argument(:pattern, :string)
      end
    end
  end
end
