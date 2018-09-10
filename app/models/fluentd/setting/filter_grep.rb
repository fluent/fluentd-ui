class Fluentd
  module Setting
    class FilterGrep
      include Fluentd::Setting::Plugin

      register_plugin("filter", "grep")

      def self.initial_params
        {
        }
      end

      def common_options
        [
          :pattern,
        ]
      end

      def hidden_options
        regexps = (1..20).map {|n| :"regexp#{n}"}
        excludes = (1..20).map {|n| :"exclude#{n}"}
        [
          *regexps, *excludes, :regexp, :exclude, :and, :or
        ].tap{|s| p s}
      end
    end
  end
end
