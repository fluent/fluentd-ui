class Fluentd
  module Setting
    module Type
      class Section < ActiveModel::Type::Value
        def type
          :section
        end

        private

        def cast_value(value)
          value
        end
      end
    end
  end
end
