class Fluentd
  module Setting
    module Type
      class Hash < ActiveModel::Type::Value
        def type
          :hash
        end

        private

        def cast_value(value)
          value
        end
      end
    end
  end
end
