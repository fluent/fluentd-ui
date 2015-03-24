# for read Fluent::TextParser::TEMPLATE_REGISTRY
require "fluent/registry"
require "fluent/configurable"
require "fluent/parser"

class RegexpPreview
  attr_reader :file, :format, :params, :time_format, :regexp

  def initialize(file, format, params = {}, options = {})
    @file = file
    @format = format
    @params = params
    case format
    when "regexp"
      @regexp = Regexp.new(options[:regexp])
      @time_format = options[:time_format]
      @strategy = :matches_single_line
    when "multiline"
      @strategy = :matches_multiline
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
    return [] unless @strategy # such as ltsv, json, etc
    send(@strategy)
  end

  private

  def matches_single_line
    reader = FileReverseReader.new(File.open(file))
    matches = reader.tail(Settings.in_tail_preview_target_line).map do |line|
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

  def matches_multiline
    return [] if multiline_regexps.empty?
    reader = FileReverseReader.new(File.open(file))
    result = []
    target_lines = reader.tail(Settings.in_tail_preview_target_line).map{|line| line << "\n" }
    target_lines.each_with_index do |line, line_no|
      if line.match(params[:format_firstline])
        lines = target_lines[line_no, multiline_regexps.length]
        next if lines.length < multiline_regexps.length
        ret = multiline_detect(lines, multiline_regexps)
        next unless ret
        result << ret
      end
    end
    result
  end

  def multiline_detect(lines, regexps)
    whole = ""
    matches = []
    lines.each_with_index do |line, j|
      m = line.match(multiline_regexps[j])
      unless m
        return nil
      end
      m.names.each_with_index do |name, index|
        matches << {
          key: name,
          matched: m[name],
          pos: m.offset(index + 1).map{|pos| pos + whole.length},
        }
      end
      whole << line
    end
    {
      whole: whole,
      matches: matches,
    }
  end

  def multiline_regexps
    @multiline_regexps ||= (1..20).map do |n|
      params["format#{n}"].presence
    end.compact
  end
end
