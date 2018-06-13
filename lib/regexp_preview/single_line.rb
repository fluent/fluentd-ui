module RegexpPreview
  class SingleLine
    attr_reader :file, :format, :params, :regexp, :time_format

    def initialize(file, parse_type, params = {})
      @file = file
      @parse_type = parse_type
      @time_format = params[:time_format]
      @params = params

      case parse_type
      when "regexp"
        @regexp = Regexp.new(params[:regexp])
        @time_format = nil
      when "ltsv", "json", "csv", "tsv"
        @regexp = nil
        @time_format = nil
      else # apache, nginx, etc
        parser_plugin = Fluent::Plugin.new_parser(parse_type)
        raise "Unknown parse type '#{parse_type}'" unless parser_plugin
        parser_plugin.configure(Fluent::Config::Element.new('ROOT', '', {}, [])) # NOTE: SyslogParser define @regexp in configure method so call it to grab Regexp object
        @regexp = parser_plugin.instance_variable_get(:@regexp)
        @time_format = parser_plugin.time_format
      end
    end

    def matches_json
      {
        params: {
          setting: {
            # NOTE: regexp and time_format are used when parse_type == 'apache' || 'nginx' || etc.
            regexp: regexp.try(:source),
            time_format: time_format,
          }
        },
        matches: matches.compact,
      }
    end

    private

    def matches
      return [] unless @regexp # such as ltsv, json, etc
      reader = FileReverseReader.new(File.open(file))
      matches = reader.tail(Settings.in_tail_preview_line_count).map do |line|
        result = {
          :whole => line,
          :matches => [],
        }
        match = line.match(regexp)
        next result unless match

        match.names.each_with_index do |name, index|
          result[:matches] << {
            key: name,
            matched: match[name],
            pos: match.offset(index + 1),
          }
        end
        result
      end
      matches
    end
  end
end
