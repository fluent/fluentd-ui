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
        :matches => {},
      }
      m = line.match(params[:regexp])
      m.names.each do |name|
        result[:matches][name] = m[name]
      end
      result
    end
    render json: matches
  end
end

