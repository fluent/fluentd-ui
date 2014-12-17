require 'fluent/config'

class Fluentd
  module Setting
    class Config
      attr_reader :fl_config, :file
      delegate :elements, to: :fl_config

      def initialize(config_file)
        @fl_config = Fluent::Config.parse(IO.read(config_file), config_file, nil, true)
        @file = config_file
      end

      def empty?
        elements.length.zero?
      end

      def sources
        elements.find_all do |elm|
          elm.name == "source"
        end
      end

      def matches
        elements.find_all do |elm|
          elm.name == "match"
        end
      end

      def write_to_file
        return unless Fluentd.instance
        Fluentd.instance.agent.config_write formatted
      end

      def formatted
        fl_config.to_s.gsub(/<\/?ROOT>/, "").strip_heredoc.gsub(%r|^</.*?>$|, "\\0\n")
      end
    end
  end
end
