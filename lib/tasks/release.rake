namespace :release do
  desc "Add header of now version release to Changelog and bump up version"
  task :prepare do
    raise "Use this task in development only" unless Rails.env.development?

    # detect merged PR
    now_version = FluentdUI::VERSION
    pr_numbers = `git log v#{now_version}..master --oneline`.scan(/#[0-9]+/)

    if !$?.success? || pr_numbers.empty?
      puts "Detecting PR failed. Please confirm if any PR were merged after the latest release."
      exit(false)
    end

    # Generate new version
    /\.([0-9]+)\z/.match(now_version)
    now_revision = $1
    new_version = now_version.gsub(/\.#{now_revision}\z/, ".#{now_revision.to_i + 1}")

    # Update Changelog
    changelog_filename = Rails.root.join('Changelog')
    changelog = File.read(changelog_filename)

    pr_descriptions = pr_numbers.map do |number|
      "* [] #{number} https://github.com/fluent/fluentd-ui/pull/#{number.gsub('#', '')}"
    end.join("\n")

    new_changelog = <<-HEADER
Release #{new_version} - #{Time.now.strftime("%Y/%m/%d")}
#{pr_descriptions}

#{changelog.chomp}
HEADER

    File.open(changelog_filename, "w") {|f| f.write(new_changelog)}

    # Update version.rb
    version_filename = Rails.root.join("lib", "fluentd-ui", "version.rb")
    version_class = File.read(version_filename)
    new_version_class = version_class.gsub(/VERSION = \"#{now_version}\"/, "VERSION = \"#{new_version}\"")

    File.open(version_filename, 'w') {|f| f.write(new_version_class)}

    # Update Gemfile.lock
    system("bundle install")

    puts "Changelog, verion and Gemfile.lock is updated. New version is #{new_version}."
  end
end
