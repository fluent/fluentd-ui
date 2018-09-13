# pidfile
#   td-agent: /var/run/td-agent/td-agent.pid
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L18
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/deb/td-agent#L24
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/rpm/td-agent#L24
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/td-agent/logrotate.d/td-agent.logrotate#L10
#   fluentd:  nothing (or --daemon PIDFILE)
#
# logfile
#   td-agent: /var/log/td-agent/td-agent.log
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L21
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/deb/td-agent#L23
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/init.d/rpm/td-agent#L23
#   fluentd: stdout (or --log LOGFILE)
#
# config file
#   td-agent: /etc/td-agent/td-agent.conf
#   - https://github.com/treasure-data/omnibus-td-agent/blob/master/templates/etc/systemd/td-agent.service.erb#L14
#   fluentd: /etc/fluent/fluent.conf (created by fluentd -s)

require "strscan"

class Fluentd
  class Agent
    module Common
      attr_reader :extra_options

      def self.included(base)
        base.include(Fluentd::Agent::ProcessOperation)
      end

      # define these methods on each Agent class
      %w(start stop restart version).each do |method|
        define_method(method) do
          raise NotImplementedError, "'#{method}' method is required to be defined"
        end
      end

      def initialize(options = {})
        @extra_options = options
      end

      def pid_file
        extra_options[:pid_file] || self.class.default_options[:pid_file]
      end

      def log_file
        extra_options[:log_file] || self.class.default_options[:log_file]
      end

      def log
        @log ||= FluentdLog.new(log_file)
      end

      def config_file
        extra_options[:config_file] || self.class.default_options[:config_file]
      end

      # -- config
      def config
        File.read(config_file)
      end

      def config_write(content)
        backup_config
        File.open(config_file, "w") do |f|
          f.write content
        end
      end

      def config_append(content)
        backup_config
        File.open(config_file, "a") do |f|
          f.write "\n"
          f.write content
        end
      end

      def config_merge(content)
        if content.start_with?("<label ")
          label = content.slice(/<label\s+(.+?)>/, 1)
          key = "label:#{label}"
          parsed_config = parse_config(config)
          if parsed_config.key?(key)
            offset = parsed_config[key][0][:pos] + parsed_config[key][0][:size]
            label, sections = parse_label_section(content, offset)
            parsed_config[key][0][:sections]["filter"].concat(sections["filter"])
            parsed_config[key][0][:sections]["match"].concat(sections["match"])
            config_write(dump_parsed_config(parsed_config))
          else
            config_append(content)
          end
        else
          config_append(content)
        end
      end

      def configuration
        if File.exists? config_file
          ::Fluentd::Agent::Configuration.new(config_file)
        end
      end

      # -- backup methods
      def config_backup_dir
        dir = File.join(FluentdUI.data_dir, "#{Rails.env}_confg_backups")
        FileUtils.mkdir_p(dir)
        dir
      end

      def backup_files
        Dir.glob(File.join("#{config_backup_dir}", "*.conf"))
      end

      def backup_files_in_old_order
        backup_files.sort
      end

      def backup_files_in_new_order
        backup_files_in_old_order.reverse
      end

      def running_config_backup_dir
        dir = File.join(FluentdUI.data_dir, "#{Rails.env}_running_confg_backup")
        FileUtils.mkdir_p(dir)
        dir
      end

      def running_config_backup_file
        File.join(running_config_backup_dir, "running.conf")
      end

      # -------------- private --------------
      private

      def backup_running_config
        #back up config file only when start success
        return unless yield

        return unless File.exists? config_file

        FileUtils.cp config_file, running_config_backup_file

        true
      end

      def backup_config
        return unless File.exists? config_file

        FileUtils.cp config_file, File.join(config_backup_dir, "#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.conf")

        remove_over_backup_files
      end

      def remove_over_backup_files
        over_file_count = backup_files.size - ::Settings.max_backup_files_count

        return if over_file_count <= 0

        backup_files_in_old_order.first(over_file_count).each do |file|
          note_file_attached_backup = file.sub(/#{Regexp.escape(File.extname(file))}\z/, ::Fluentd::SettingArchive::Note::FILE_EXTENSION)
          FileUtils.rm(note_file_attached_backup) if File.exist? note_file_attached_backup
          FileUtils.rm(file) if File.exist? file
        end
      end

      def parse_config(content)
        scanner = StringScanner.new(content)
        contents = Hash.new {|h, k| h[k] = [] }
        until scanner.eos? do
          started = scanner.pos
          header = scanner.scan_until(/^<(source|filter|match|label)/)
          section_type = scanner[1]
          break unless header
          case section_type
          when "source", "filter", "match"
            current_source = header + scanner.scan_until(%r{^</(?:source|filter|match)>})
            contents[section_type] << { pos: started, content: current_source.strip }
          when "label"
            label_content = header + scanner.scan_until(%r{^</label>})
            label, sections = parse_label_section(label_content, started)
            contents["label:#{label}"] << { label: label, pos: started, sections: sections, size: label_content.size }
          else
            raise TypeError, "Unknown section: #{started}: #{section_type}"
          end
        end
        contents
      end

      def parse_label_section(content, offset)
        scanner = StringScanner.new(content)
        scanner.scan_until(/^<label\s+?([^\s]+?)>/)
        label = scanner[1]
        sections = Hash.new {|h, k| h[k] = [] }
        loop do
          break if scanner.match?(%r{\s+?</label>})
          pos = scanner.pos
          header = scanner.scan_until(/^\s*<(filter|match)/)
          type = scanner[1]
          source = header + scanner.scan_until(%r{^\s*</(?:filter|match)>})
          sections[type] << { label: label, pos: pos + offset, content: source.sub(/\n+/, "") }
        end
        return label, sections
      end

      def dump_parsed_config(parsed_config)
        content = "".dup
        sources = parsed_config["source"] || []
        filters = parsed_config["filter"] || []
        matches = parsed_config["match"] || []
        labels = parsed_config.select do |key, sections|
          key.start_with?("label:")
        end
        labels = labels.values.flatten
        sorted_sections = (sources + filters + matches + labels).sort_by do |section|
          section[:pos]
        end
        sorted_sections.each do |section|
          if section.key?(:label)
            label = section[:label]
            sub_filters = section.dig(:sections, "filter") || []
            sub_matches = section.dig(:sections, "match") || []
            sub_sections = (sub_filters + sub_matches).sort_by do |sub_section|
              sub_section[:pos]
            end
            content << "<label #{label}>\n"
            sub_sections.each do |sub_section|
              content << sub_section[:content] << "\n\n"
            end
            content.chomp!
            content << "</label>\n\n"
          else
            content << section[:content] << "\n\n"
          end
        end
        content.chomp
      end
    end
  end
end
