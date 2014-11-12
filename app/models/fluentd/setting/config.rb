require 'fluent/config'

class Fluentd
  module Setting
    class Config
      attr_reader :config, :file

      def initialize(config_file)
        config = Fluent::Config.parse(IO.read(config_file), config_file, nil, true)
        @config = config
        @file = config_file
      end

      def sources
        config.elements.find_all do |elm|
          elm.name == "source"
        end
      end

      def matches
        config.elements.find_all do |elm|
          elm.name == "match"
        end
      end
    end
  end
end
