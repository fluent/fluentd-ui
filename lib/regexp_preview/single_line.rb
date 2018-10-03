module RegexpPreview
  class SingleLine
    attr_reader :path, :plugin_name, :plugin_config, :plugin

    def initialize(path, plugin_name, plugin_config = {})
      @path = path
      @plugin_name = plugin_name.to_sym
      @plugin_config = plugin_config

      config = Fluent::Config::Element.new("ROOT", "", @plugin_config, [])
      @plugin = Fluent::Plugin.new_parser(@plugin_name).tap do |instance|
        instance.configure(config)
      end
    end

    def matches
      {
        pluginConfig: @plugin_config,
        matches: _matches
      }
    end

    private

    def _matches
      return [] if %i(json csv tsv ltsv).include?(@plugin_name)
      begin
        io = File.open(path)
        reader = FileReverseReader.new(io)
        parsed_lines = reader.tail(Settings.in_tail_preview_line_count).map do |line|
          parsed = {
            whole: line,
            matches: []
          }
          @plugin.parse(line) do |time, record|
            next unless record
            last_pos = 0
            record.each do |key, value|
              v = value.to_s
              start = line.index(v, last_pos)
              finish = start + v.bytesize
              last_pos = finish
              parsed[:matches] << {
                key: key,
                matched: v,
                pos: [start, finish]
              }
            end
          end
          parsed
        end
        parsed_lines.reject do |parsed|
          parsed[:matches].blank?
        end
      ensure
        io.close
      end
    end
  end
end
