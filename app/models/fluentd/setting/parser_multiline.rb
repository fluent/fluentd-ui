class Fluentd
  module Setting
    class ParserMultiline
      include Fluentd::Setting::Plugin

      register_plugin("parser", "multiline")

      FORMAT_MAX_NUM = 20

      (1..FORMAT_MAX_NUM).each do |n|
        config_param("format#{n}", :string)
      end

      def self.initial_params
        {}
      end

      def common_options
        [:format_firstline] +
          (1..FORMAT_MAX_NUM).to_a.map{|n| "format#{n}".to_sym }
      end
    end
  end
end
