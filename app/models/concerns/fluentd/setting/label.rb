class Fluentd
  module Setting
    module Label
      extend ActiveSupport::Concern

      included do
        config_param(:label, :string)
      end
    end
  end
end
