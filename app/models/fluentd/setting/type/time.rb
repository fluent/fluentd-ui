class Fluentd
  module Setting
    module Type
      class Time < ActiveModel::Type::Value
        def type
          :fluentd_time
        end

        private

        def cast_value(value)
          value
        end
      end
    end
  end
end
