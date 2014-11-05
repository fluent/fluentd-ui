namespace :dep do
  desc "list dependency gems order by less referenced"
  task :list do
    require "set"
    deps = Set.new
    context = false
    current_parent  = false
    versions = {
      "bundler" => "1.7.4" # bundler version does not appear in Gemfile.lock
    }
    lock_file = ENV["GEMFILE_LOCK"] || "Gemfile.production.lock"
    File.open(lock_file).each_line do |line|
      # GEM
      #   remote: https://rubygems.org/
      #   specs:
      #     foo_gem (0.1.2)
      #       foo_dep1 (>= 1.0.0)
      #       foo_dep2
      #     bar_gem (1.2.1)
      #       bar_dep1
      #       ...
      #   ...
      if line == "  specs:\n"
        context = true
        next
      end
      gem_name = line[/[^ \n]+/, 0] # "    foo_gem (0.1.2)\n" => "foo_gem"
      if line.match(/^ {4}[^ ]/)    # "    foo_gem (0.1.2)"
        current_parent = gem_name
        versions[current_parent] = line[/\((.*?)\)/, 1] # foobar (1.2.3) => 1.2.3
        next
      elsif line.match(/^ {6}[^ ]/) # "      foo_dep1 (>= 1.0.0)"
        deps.add([current_parent, gem_name])
      else
        context = false
      end
    end
    rank = {}
    deps.to_a.each do |(parent, child)|
      rank[parent] ||= 0
      rank[child] ||= 0
      rank[parent] += 1
    end
    rank.to_a.sort_by {|(name, score)| score }.each do |(name, score)|
      puts %Q|download "#{name}", "#{versions[name]}"|
    end
  end
end
