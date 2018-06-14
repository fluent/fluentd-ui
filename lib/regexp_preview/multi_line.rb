module RegexpPreview
  class MultiLine
    attr_reader :path, :plugin_name, :plugin_config, :plugin

    def initialize(path, plugin_name, plugin_config = {})
      @path = path
      @plugin_name = plugin_name
      @plugin_config = plugin_config

      config = Fluent::Config::Element.new("ROOT", "", @plugin_config, [])
      @plugin = Fluent::Plugin.new_parser(@plugin_name).tap do |instance|
        instance.configure(config)
      end
    end

    def matches
      {
        pluginConfig: @plugin_config,
        matches: _matches,
      }
    end

    private

    def _matches
      begin
        io = File.open(path)
        reader = FileReverseReader.new(io)
        parserd_chunks = []
        target_lines = reader.tail(Settings.in_tail_preview_line_count).map{|line| line << "\n" }
        whole_string = target_lines.join
        firstline_regex = Regexp.new(plugin_config["format_firstline"][1..-2])
        indexes = []
        cur = 0
        while first_index = whole_string.index(firstline_regex, cur)
          indexes << first_index
          cur = first_index + 1
        end
        indexes.each_with_index do |index, i|
          next_index = indexes[i + 1] || -1
          chunk = whole_string[index...next_index]
          parsed = {
            whole: chunk,
            matches: []
          }
          @plugin.parse(chunk) do |time, record|
            next unless record
            last_pos = 0
            record.each do |key, value|
              start = chunk.index(value, last_pos)
              finish = start + value.bytesize
              last_pos = finish
              parsed[:matches] << {
                key: key,
                matched: value,
                pos: [start, finish]
              }
            end
          end
          parserd_chunks << parsed
        end
        parserd_chunks.reject do |parsed|
          parsed[:matches].blank?
        end
      ensure
        io.close
      end
    end
  end
end
