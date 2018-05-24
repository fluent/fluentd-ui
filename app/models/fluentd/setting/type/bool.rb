class Fluentd
  module Setting
    module Type
      class Bool < ActiveModel::Type::Value
        def type
          :bool
        end

        private

        def cast_value(value)
          # TODO Use type converter method of Fluentd
          value
        end
      end
    end
  end
end
