class Fluentd
  module Setting
    module Type
      class Bool < ActiveModel::Type::Value
        def type
          :bool
        end

        private

        def cast_value(value)
          # TODO Fluentd の型変換を使う
          value
        end
      end
    end
  end
end
