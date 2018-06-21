class Fluentd
  module Setting
    module Type
      class Object < ActiveModel::Type::Value
        def type
          :object
        end

        private

        def cast_value(value)
          value
        end
      end
    end
  end
end
