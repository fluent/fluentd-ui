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
    else
      definition = Fluent::TextParser::TEMPLATE_REGISTRY.lookup(format)
      raise "Unknown format '#{format}'" unless definition
      @regexp = definition.patterns["format"]
      @time_format = options[:time_format] || definition.patterns["format"]
    end
  end

  def matches
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
