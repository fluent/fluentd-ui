class Fluentd
  module Setting
    class FilterGrep
      include Fluentd::Setting::Plugin

      register_plugin("filter", "grep")

      def self.initial_params
        {
        }
      end

      def self.permit_params
        [
          :pattern, :log_level, :@log_level,
          { and: {regexp: [:key, :pattern], exclude: [:key, :pattern]} },
          { or: {regexp: [:key, :pattern], exclude: [:key, :pattern]} }
        ]
      end

      def common_options
        [
          :pattern
        ]
      end

      def hidden_options
        regexps = (1..20).map {|n| :"regexp#{n}"}
        excludes = (1..20).map {|n| :"exclude#{n}"}
        [
          *regexps, *excludes, :regexp, :exclude, :and, :or
        ]
      end
    end
  end
end
