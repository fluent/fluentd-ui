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
    preview = RegexpPreview.processor(params[:format]).new(params[:file], params[:format], params)
    matches = preview.matches

    render json: {
      params: {
        setting: {
          # NOTE: regexp and timeformat are used when format == 'apache' || 'nginx' || etc.
          # TODO: prepare rendered JSON by prcessor(RegexpPreview::{Signle,Multi}Line
          regexp: preview.try(:regexp).try(:source),
          time_format: preview.try(:time_format),
        }
      },
      matches: matches.compact,
    }
  end

  def grok_to_regexp
    grok = GrokConverter.new
    grok.load_patterns
    render text: grok.convert_to_regexp(params[:grok_str]).source
  end
end

