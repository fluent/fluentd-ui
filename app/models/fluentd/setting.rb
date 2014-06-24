class Fluentd
  module Setting
    class InTail
      include ActiveModel::Model
      attr_accessor :path, :tag, :format, :regexp, :time_format, :rotate_wait, :pos_file, :read_from_head, :refresh_interval

      validates :path, presence: true
      validates :tag, presence: true
      #validates :format, presence: true

      def self.known_formats
        {
          :apache2 => [:time_format],
          :nginx => [:time_format],
          :syslog => [:time_format],
          :tsv => [:keys, :time_key],
          :csv => [:keys, :time_key],
          :ltsv => [:delimiter, :time_key],
          :json => [:time_key],
          :grok => [:grok_str],
        }
      end
      attr_accessor *known_formats.values.flatten.compact

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
          :grok
        end
      end

      def extra_format_options
        self.class.known_formats[format.to_sym] || []
      end

      def format_specific_conf
        return "" if %w(grok regexp).include?(format)

        indent = " " * 2
        format_specific_conf = ""
        extra_format_options.each do |key|
          format_specific_conf << "#{indent}#{key} #{send(key)}\n"
        end
        format_specific_conf
      end

      def certain_format_line
        case format
        when "grok"
          "format /#{grok.convert_to_regexp(grok_str).source.gsub("/", "\\/")}/ # grok: '#{grok_str}'" # TODO: convert to regexp
        when "regexp"
          "format #{regexp}"
        else
          "format #{format}"
        end
      end

      def grok
        @grok ||=
          begin
            grok = GrokConverter.new
            grok.load_patterns(Rails.root + "vendor/patterns")
            grok
          end
      end

      def to_conf
        # NOTE: Using strip_heredoc makes more complex for format_specific_conf indent
        <<-XML.gsub(/^[ ]*\n/m, "")
<source>
  type tail
  path #{path}
  tag #{tag}
  #{certain_format_line}
#{format_specific_conf}

  #{read_from_head.to_i.zero? ? "" : "read_from_head true"}
  #{pos_file.present? ? "pos_file #{pos_file}" : ""}
  #{rotate_wait.present? ? "rotate_wait #{rotate_wait}" : ""}
  #{refresh_interval.present? ? "refresh_interval #{refresh_interval}" : ""}
</source>
        XML
      end
    end
  end
end
