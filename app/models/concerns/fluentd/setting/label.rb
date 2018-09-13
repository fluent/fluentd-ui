class Fluentd
  module Setting
    module Label
      extend ActiveSupport::Concern

      included do
        config_argument(:label, :string)
      end
    end
  end
end
