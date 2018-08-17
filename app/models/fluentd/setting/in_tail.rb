require "fluent/plugin/parser_multiline"

class Fluentd
  module Setting
    class InTail
      include Fluentd::Setting::Plugin

      register_plugin("input", "tail")
      # TODO support formatN ???

      MULTI_LINE_MAX_FORMAT_COUNT = ::Fluent::Plugin::MultilineParser::FORMAT_MAX_NUM

      def guess_parse_type
        case path
        when /\.json$/
          :json
        when /\.csv$/
          :csv
        when /\.tsv$/
          :tsv
        when /\.ltsv$/
          :ltsv
        when /nginx/
          :nginx
        when /apache/
          :apache2
        when %r|/var/log|
          :syslog
        else
          :regexp
        end
      end
    end
  end
end
