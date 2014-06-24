class GrokConverter
  def load_patterns(dir)
    @patterns = {}
    Dir.glob("#{dir}/*").each do |file|
      File.read(file).split("\n").each do |line|
        line.strip!
        next if line == ""
        next if line.start_with?("#")
        name, pattern = line.split(/\s+/, 2)
        next unless pattern
        @patterns[name] = pattern
      end
    end
  end

  def convert_to_regexp(pattern)
    limit = 100
    expanded = pattern.dup
    while m = expanded.match(/%{(.*?)(?::(.*?))?}/) # %{key:name} or #{key}
      all, key, name = *m
      if name
        expanded = expanded.gsub(all, "(?<#{name}>#{@patterns[key]})")
      else
        expanded = expanded.gsub(all, @patterns[key])
      end
      limit -= 1
      break if limit == 0
    end
    Regexp.new expanded
  end
end

=begin
  g = GrokConverter.new
  g.load_patterns("vendor/patterns")
  p g.convert_to_regexp("%{USERNAME:user} %{NOT_EXISTS:foo} %{USER} aaaa")
  # => /(?<user>[a-zA-Z0-9._-]+) (?<foo>) [a-zA-Z0-9._-]+ aaaa/
=end
