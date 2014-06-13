class ApiController < ApplicationController
  def tree
    render json: Treeview.tree(params[:path])
  end

  def file_preview
    return empty_json unless params[:file]
    return empty_json unless File.exists? params[:file]
    file = params[:file]
    sample = File.read(file, 1024) || ""
    sample2 = sample.force_encoding('ascii-8bit').encode('us-ascii', :undef => :replace, :invalid => :replace, :replace => "")
    return empty_json if sample != sample2 # maybe binary file

    reader = FileReverseReader.new(File.open(file))
    render json: reader.enum_for(:each_line).to_a.first(10).reverse
  end

  def empty_json
    render json: []
  end
end
