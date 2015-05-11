class Fluentd::RecipesController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :set_recipes, only: [:show, :apply]

  def index
    @recipes = ::Fluentd::Recipe.all
  end

  def show
  end

  def apply
    conf = ""
    @recipe.models.each do |model_class|
      model_params = params[model_class.model_name.param_key]
      m = model_class.new(model_class.initial_params.merge(model_params))
      conf << m.to_config
      conf << $/
    end
    render text: conf, content_type: :text
  end

  private

  def set_recipes
    @recipe = ::Fluentd::Recipe.new(params[:id])
  end
end
