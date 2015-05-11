class Fluentd
  class Recipe
    include ActiveModel::Model

    def self.all
      definitions.keys.map{|id| new(id) }
    end

    def self.definitions
      YAML.load_file(Rails.root.join("config", "recipes.yml"))
    end

    attr_reader :id, :value

    def initialize(id)
      @id = id
      @value = self.class.definitions[@id]
    end

    def conf
      File.read(Rails.root.join("data", "recipes", "#{@id}.conf"))
    end

    def description
      value["description"]
    end

    def models
      value["plugins"].map do |model_name|
        Fluentd::Setting.const_get(model_name)
      end
    end

    def required_attributes
      @attributes ||= value["settings"]
    end

    def plugins
      models.map do |model|
        model.plugin
      end.compact
    end
  end
end
