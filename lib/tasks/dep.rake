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
    skip_gems = %w(fluentd)
    lock_file = "Gemfile.production.lock"
    unless ENV["SKIP_BUNDLE_INSTALL"]
      system("bundle install --gemfile Gemfile.production", out: STDERR) # ensure lock file is up to date
    end

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
        if skip_gems.include?(gem_name)
          current_parent = nil
          next
        end
        current_parent = gem_name
        versions[current_parent] = line[/\((.*?)\)/, 1] # foobar (1.2.3) => 1.2.3
        next
      elsif line.match(/^ {6}[^ ]/) # "      foo_dep1 (>= 1.0.0)"
        next if skip_gems.include?(gem_name)
        next if current_parent.blank?
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
