# for read Fluent::TextParser::TEMPLATE_REGISTRY
require "fluent/registry"
require "fluent/configurable"
require "fluent/parser"
require "regexp_preview/single_line"
require "regexp_preview/multi_line"

module RegexpPreview
  def self.processor(parse_type)
    case parse_type
    when "multiline"
      RegexpPreview::MultiLine
    else
      RegexpPreview::SingleLine
    end
  end
end
