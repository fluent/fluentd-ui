class ApiController < ApplicationController
  def tree
    render json: Treeview.tree(params[:path])
  end

  def file_preview
    render json: file_tail(params[:file]) || []
  end

  def empty_json
    render json: []
  end

  def regexp_preview
    matches = file_tail(params[:file]).map do |line|
      result = {
        :whole => line,
        :matches => [],
      }
      m = line.match(params[:regexp])
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
    render json: matches.compact
  end

  def grok_to_regexp
    grok = GrokConverter.new
    grok.load_patterns
    render text: grok.convert_to_regexp(params[:grok_str]).source
  end
end

