class Fluentd
  module Setting
    module Type
      class Size < ActiveModel::Type::Value
        def type
          :size
        end

        private

        def cast_value(value)
          value
        end
      end
    end
  end
end
