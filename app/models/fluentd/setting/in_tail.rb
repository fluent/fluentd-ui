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

      def extra_format_options
        self.class.known_formats[format.to_sym] || []
      end

      def format_specific_conf
        return "" if %w(grok regexp).include?(format)

        indent = " " * 2
        format_specific_conf = ""

        if format.to_sym == :multiline
          known_formats[:multiline].each do |key|
            value = send(key)
            if value.present?
              format_specific_conf << "#{indent}#{key} /#{value}/\n"
            end
          end
        else
          extra_format_options.each do |key|
            format_specific_conf << "#{indent}#{key} #{send(key)}\n"
          end
        end

        format_specific_conf
      end

      def certain_format_line
        case format
        when "grok"
          "format /#{grok.convert_to_regexp(grok_str).source.gsub("/", "\\/")}/ # grok: '#{grok_str}'"
        when "regexp"
          "format /#{regexp}/"
        else
          "format #{format}"
        end
      end

      def grok
        @grok ||=
          begin
            grok = GrokConverter.new
            grok.load_patterns
            grok
          end
      end
    end
  end
end
