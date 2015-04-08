module RegexpPreview
  class SingleLine
    attr_reader :file, :format, :params, :regexp

    def initialize(file, format, params = {})
      @file = file
      @format = format
      @params = params
      case format
      when "regexp"
        @regexp = Regexp.new(params[:regexp])
      when "ltsv", "json", "csv", "tsv"
      else # apache, nginx, etc
        definition = Fluent::TextParser::TEMPLATE_REGISTRY.lookup(format).call
        raise "Unknown format '#{format}'" unless definition
        definition.configure({}) # NOTE: SyslogParser define @regexp in configure method so call it to grab Regexp object
        @regexp = definition.patterns["format"]
      end
    end

    def matches
      return [] unless @regexp # such as ltsv, json, apache, etc
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
