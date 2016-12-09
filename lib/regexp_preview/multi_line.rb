module RegexpPreview
  class MultiLine
    attr_reader :file, :format, :params

    def initialize(file, format, params = {})
      @file = file
      @format = format
      @params = params[:params]
    end

    def matches_json
      {
        params: {
          setting: { # for vue.js
            regexp: nil,
            time_format: nil,
          }
        },
        matches: matches.compact,
      }
    end

    private

    def matches
      return [] if patterns.empty?
      reader = FileReverseReader.new(File.open(file))
      result = []
      target_lines = reader.tail(Settings.in_tail_preview_line_count).map{|line| line << "\n" }
      whole_string = target_lines.join
      re_firstline = Regexp.new(params[:format_firstline])
      indexes = []
      cur = 0
      while first_index = whole_string.index(re_firstline, cur)
        indexes << first_index
        cur = first_index + 1
      end
      indexes.each_with_index do |index, i|
        next_index = indexes[i + 1] || -1
        chunk = whole_string[index...next_index]
        ret = detect_chunk(chunk)
        next unless ret
        result << ret
      end
      result
    end

    def detect_chunk(chunk)
      whole = ""
      matches = []
      offset = 0
      patterns.each do |pat|
        match = chunk.match(pat)
        return nil unless match
        offset = chunk.index(pat)
        return nil if offset > 0
        chunk = chunk[match[0].length..-1]
        match.names.each_with_index do |name, index|
          matches << {
            key: name,
            matched: match[name],
            pos: match.offset(index + 1).map{|pos| pos + whole.length},
          }
        end
        whole << match[0]
      end
      {
        whole: whole,
        matches: matches,
      }
    end

    def patterns
      @patterns ||= (1..20).map do |n|
        params["format#{n}"].presence
      end.compact.map {|pattern| Regexp.new(pattern, Regexp::MULTILINE)}
    end
  end
end

