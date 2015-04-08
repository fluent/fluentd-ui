module RegexpPreview
  class MultiLine
    attr_reader :file, :format, :params

    def initialize(file, format, params = {})
      @file = file
      @format = format
      @params = params[:params]
    end

    def matches
      return [] if patterns.empty?
      reader = FileReverseReader.new(File.open(file))
      result = []
      target_lines = reader.tail(Settings.in_tail_preview_line_count).map{|line| line << "\n" }
      target_lines.each_with_index do |line, line_no|
        if line.match(params[:format_firstline])
          lines = target_lines[line_no, patterns.length]
          next if lines.length < patterns.length
          ret = detect_chunk(lines)
          next unless ret
          result << ret
        end
      end
      result
    end

    private

    def detect_chunk(lines)
      whole = ""
      matches = []
      lines.each_with_index do |line, i|
        match = line.match(patterns[i])
        return nil unless match
        match.names.each_with_index do |name, index|
          matches << {
            key: name,
            matched: match[name],
            pos: match.offset(index + 1).map{|pos| pos + whole.length},
          }
        end
        whole << line
      end
      {
        whole: whole,
        matches: matches,
      }
    end

    def patterns
      @patterns ||= (1..20).map do |n|
        params["format#{n}"].presence
      end.compact.map {|pattern| Regexp.new(pattern)}
    end
  end
end

