require 'fluent/config'

class Fluentd
  module Setting
    class Config
      attr_reader :fl_config, :file
      delegate :elements, to: :fl_config

      def initialize(config_file)
        @fl_config = Fluent::Config.parse(IO.read(config_file), config_file, nil, true)
        @file = config_file
      end

      def empty?
        elements.length.zero?
      end

      def sources
        elements.find_all do |elm|
          elm.name == "source"
        end
      end

      def filters
        elements.find_all do |elm|
          elm.name == "filter"
        end
      end

      def matches
        elements.find_all do |elm|
          elm.name == "match"
        end
      end

      def labels
        elements.find_all do |elm|
          elm.name == "label"
        end
      end

      def group_by_label
        hash = Hash.new{|h, k| h[k] = {} }
        sources.each do |source|
          label = source["@label"] || source["label"]
          if label
            hash[label][:sources] = [source]
          else
            hash["ROOT"][:sources] = [source]
          end
        end
        hash["ROOT"][:filters] = filters unless filters.empty?
        hash["ROOT"][:matches] = matches unless matches.empty?

        labels.each do |label|
          hash[label.arg][:filters] = label.elements.find_all do |e|
            e.name == "filter"
          end
          hash[label.arg][:matches] = label.elements.find_all do |e|
            e.name == "match"
          end
        end
        hash
      end

      def delete_element(name, arg, element)
        if name == "label"
          label_section = fl_config.elements(name: name, arg: arg).first
          original_size = label_section.elements.size
          remaining_elements = label_section.elements.reject do |e|
            element == e
          end
          if remaining_elements.empty?
            remaining_elements = fl_config.elements.reject do |e|
              label_section == e
            end
            fl_config.elements = remaining_elements
            return element
          else
            label_section.elements = remaining_elements
            if original_size == label_section.elements.size
              return nil
            else
              return element
            end
          end
        else
          original_size = fl_config.elements.size
          remaining_elements = fl_config.elements.reject do |e|
            element == e
          end
          fl_config.elements = remaining_elements
          if original_size == fl_config.elements.size
            return nil
          else
            return element
          end
        end
      end

      def write_to_file
        return unless Fluentd.instance
        Fluentd.instance.agent.config_write formatted
      end

      def formatted
        fl_config.to_s.gsub(/<\/?ROOT>/, "").strip_heredoc.gsub(%r|^</.*?>$|, "\\0\n")
      end
    end
  end
end
