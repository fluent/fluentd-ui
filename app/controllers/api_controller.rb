class ApiController < ApplicationController
  def tree
    render json: Treeview.tree(params[:path])
  end

  def file_preview
    file = params[:file]
    unless File.exists?(file)
      return render json: [], status: 404
    end
    unless File.file?(file) && File.readable?(file)
      return render json: [], status: 403
    end
    render json: file_tail(file)
  end

  def empty_json
    render json: []
  end

  def regexp_preview
    preview = RegexpPreview.processor(params[:parse_type]).new(params[:file], params[:parse_type], params)

    render json: preview.matches
  end

  def grok_to_regexp
    grok = GrokConverter.new
    grok.load_patterns
    render text: grok.convert_to_regexp(params[:grok_str]).source
  end
end
