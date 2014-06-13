class ApiController < ApplicationController
  def tree
    render json: Treeview.tree(params[:path])
  end
end
