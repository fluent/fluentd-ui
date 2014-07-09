# for read Fluent::TextParser::TEMPLATE_REGISTRY
require "fluent/registry"
require "fluent/configurable"
require "fluent/parser"

class RegexpPreview
  attr_reader :file, :format, :time_format, :regexp

  def initialize(file, format, options = {})
    @file = file
    @format = format
    case format
    when "regexp"
      @regexp = Regexp.new(options[:regexp])
      @time_format = options[:time_format]
    when "ltsv", "json", "csv", "tsv"
    else
      definition = Fluent::TextParser::TEMPLATE_REGISTRY.lookup(format).call
      raise "Unknown format '#{format}'" unless definition
      definition.configure({}) # NOTE: SyslogParser define @regexp in configure method so call it to grab Regexp object
      @regexp = definition.patterns["format"]
      @time_format = definition.patterns["time_format"]
    end
  end

  def matches
    return [] unless @regexp # such as ltsv, json, etc
    reader = FileReverseReader.new(File.open(file))
    matches = reader.tail.map do |line|
      result = {
        :whole => line,
        :matches => [],
      }
      m = line.match(regexp)
      next result unless m

      m.names.each_with_index do |name, index|
        result[:matches] << {
          key: name,
          matched: m[name],
          pos: m.offset(index + 1),
        }
      end
      result
    end
    matches
  end
end
