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
    plugin_config = prepare_plugin_config || {}
    preview = RegexpPreview.processor(params[:parse_type]).new(params[:file], params[:parse_type], plugin_config)

    render json: preview.matches
  rescue Fluent::ConfigError => ex
    render json: { error: "#{ex.class}: #{ex.message}" }
  end

  def grok_to_regexp
    grok = GrokConverter.new
    grok.load_patterns
    render text: grok.convert_to_regexp(params[:grok_str]).source
  end

  private

  def prepare_plugin_config
    plugin_config = params[:plugin_config]
    case params[:parse_type]
    when "multiline"
      plugin_config[:formats].lines.each.with_index do |line, index|
        plugin_config["format#{index + 1}"] = line.chomp
      end
      plugin_config
    else
      plugin_config
    end
  end
end
