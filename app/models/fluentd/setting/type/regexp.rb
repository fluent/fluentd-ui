class Fluentd
  module Setting
    module Type
      class Regexp < ActiveModel::Type::Value
        def type
          :regexp
        end

        private

        def cast_value(value)
          value
        end
      end
    end
  end
end
