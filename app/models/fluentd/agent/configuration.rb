require "fluent/config/v1_parser"

class Fluentd
  class Agent
    class Configuration
      include Enumerable

      attr_reader :file

      def initialize(config_file)
        @file = config_file
      end

      def config
        @config ||= ::Fluent::Config::V1Parser.read(file)
      end

      def to_s
        config.to_s.gsub(/\A<ROOT>\n/, "").gsub(/<\/ROOT>\n\z/, "").gsub(/^ {2}/, "")
      end

      def each(&block)
        config.each_element(&block)
      end

      def sources
        find_all{|e| e.name == "source"}
      end

      def matches
        find_all{|e| e.name == "match"}
      end
    end
  end
end
