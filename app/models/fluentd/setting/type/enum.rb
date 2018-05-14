class Fluentd
  module Setting
    module Type
      class Enum < ActiveModel::Type::Value
        def type
          :enum
        end

        private

        def cast_value(value)
          value
        end
      end
    end
  end
end
