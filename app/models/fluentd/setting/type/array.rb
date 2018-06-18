class Fluentd
  module Setting
    module Type
      class Array < ActiveModel::Type::Value
        def type
          :array
        end

        private

        def cast_value(value)
          value
        end
      end
    end
  end
end
