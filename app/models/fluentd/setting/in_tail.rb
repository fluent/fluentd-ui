require "fluent/plugin/parser_multiline"

class Fluentd
  module Setting
    class InTail
      include Fluentd::Setting::Plugin

      register_plugin("input", "tail")
      # TODO support formatN ???

      MULTI_LINE_MAX_FORMAT_COUNT = ::Fluent::Plugin::MultilineParser::FORMAT_MAX_NUM

      def self.known_formats
        {
          :apache2 => [:time_format],
          :nginx => [:time_format],
          :syslog => [:time_format],
          :tsv => [:keys, :time_key],
          :csv => [:keys, :time_key],
          :ltsv => [:delimiter, :time_key],
          :json => [:time_key],
          :regexp => [:time_format, :regexp],
          :multiline => [:format_firstline] + (1..MULTI_LINE_MAX_FORMAT_COUNT).map{|n| "format#{n}".to_sym }
          # TODO: Grok could generate Regexp including \d, \s, etc. fluentd config parser raise error with them for escape sequence check.
          #       TBD How to handle Grok/Regexp later, just comment out for hide
          # :grok => [:grok_str],
        }
      end
      attr_accessor(*known_formats.values.flatten.compact.uniq)

      def known_formats
        self.class.known_formats
      end

      def guess_format
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

      def to_conf
        # NOTE: Using strip_heredoc makes more complex for format_specific_conf indent
        <<-CONFIG.gsub(/^[ ]*\n/m, "")
<source>
  @type tail
  path #{path}
  tag #{tag}
  #{certain_format_line}
#{format_specific_conf}

  #{read_from_head.to_i.zero? ? "" : "read_from_head true"}
  #{pos_file.present? ? "pos_file #{pos_file}" : ""}
  #{rotate_wait.present? ? "rotate_wait #{rotate_wait}" : ""}
  #{refresh_interval.present? ? "refresh_interval #{refresh_interval}" : ""}
</source>
        CONFIG
      end
    end
  end
end
