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
end
