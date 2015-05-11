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
    settings = @recipe.models.map do |model_class|
      [model_class.model_name.element, params[model_class.model_name.param_key]]
    end.to_h

    erb = ERB.new(@recipe.conf)
    render text: erb.result(binding), content_type: :text
  end

  private

  def set_recipes
    @recipe = ::Fluentd::Recipe.new(params[:id])
  end
end
