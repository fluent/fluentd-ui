Plugin.installed.each do |pl|
  GemUpdateCheck.new.async.perform(pl.gem_name)
end
