require "test_helper"

class Fluentd
  class TestAgentCommon < ActiveSupport::TestCase
    class DummyAgent
      include ::Fluentd::Agent::Common
    end

    setup do
      @agent = DummyAgent.new
    end

    sub_test_case "#parse_config" do
      test "empty" do
        actual = @agent.__send__(:parse_config, "")
        assert_equal({}, actual)
      end

      test "simple" do
        actual = @agent.__send__(:parse_config, fixture_content("config/simple.conf"))
        source_section_content = <<-CONFIG.strip_heredoc.chomp
        <source>
          @type dummy
          tag dummy
        </source>
        CONFIG
        filter_section_content = <<-CONFIG.strip_heredoc.chomp
        <filter dummy>
          @type stdout
        </filter>
        CONFIG
        match_section_content = <<-CONFIG.strip_heredoc.chomp
        <match dummy>
          @type stdout
        </match>
        CONFIG
        expected = {
          "source" => [
            { pos: 0, content: source_section_content }
          ],
          "filter" => [
            { pos: 44, content: filter_section_content }
          ],
          "match" => [
            { pos: 85, content: match_section_content }
          ]
        }
        assert_equal(expected, actual)
      end

      test "simple label" do
        actual = @agent.__send__(:parse_config, fixture_content("config/label.conf"))
        source_section_content = <<-CONFIG.strip_heredoc.chomp
        <source>
          @type dummy
          tag dummy
          @label @INPUT
        </source>
        CONFIG
        filter_section_content = <<-CONFIG.chomp
  <filter dummy>
    @type stdout
  </filter>
        CONFIG
        match_section_content = <<-CONFIG.chomp
  <match dummy>
    @type stdout
  </match>
        CONFIG
        sections = {
          "filter" => [
            { label: "@INPUT", pos: 76, content: filter_section_content}
          ],
          "match" => [
            { label: "@INPUT", pos: 122, content: match_section_content}
          ]
        }
        expected = {
          "source" => [
            { pos: 0, content: source_section_content }
          ],
          "label:@INPUT" => [
            { label: "@INPUT", pos: 60, sections: sections, size: 116 }
          ]
        }
        assert_equal(expected, actual)
      end

      test "multiple labels" do
        actual = @agent.__send__(:parse_config, fixture_content("config/multi-label.conf"))
        source_section_content1 = <<-CONFIG.strip_heredoc.chomp
        <source>
          @type dummy
          tag dummy1
          @label @INPUT
        </source>
        CONFIG
        source_section_content2 = <<-CONFIG.strip_heredoc.chomp
        <source>
          @type dummy
          tag dummy2
          @label @INPUT
        </source>
        CONFIG
        filter_section_content = <<-CONFIG.chomp
  <filter dummy1>
    @type stdout
  </filter>
        CONFIG
        match_section_content = <<-CONFIG.chomp
  <match dummy1>
    @type relabel
    @label @MAIN
  </match>
        CONFIG
        input_sections = {
          "filter" => [
            { label: "@INPUT", pos: 140, content: filter_section_content }
          ],
          "match" => [
            { label: "@INPUT", pos: 187, content: match_section_content }
          ]
        }
        filter_secion_content1 = <<-CONFIG.chomp
  <filter dummy1>
    @type stdout
  </filter>
        CONFIG
        filter_secion_content2 = <<-CONFIG.chomp
  <filter dummy2>
    @type stdout
  </filter>
        CONFIG
        match_secion_content1 = <<-CONFIG.chomp
  <match dummy1>
    @type stdout
  </match>
        CONFIG
        match_secion_content2 = <<-CONFIG.chomp
  <match dummy2>
    @type stdout
  </match>
        CONFIG
        main_sections = {
          "filter" => [
            { label: "@MAIN", pos: 275, content: filter_secion_content1 },
            { label: "@MAIN", pos: 322, content: filter_secion_content2 }
          ],
          "match" => [
            { label: "@MAIN", pos: 370, content: match_secion_content1 },
            { label: "@MAIN", pos: 416, content: match_secion_content2 }
          ]
        }
        expected = {
          "source" => [
            { pos: 0, content: source_section_content1 },
            { pos: 61, content: source_section_content2 },
          ],
          "label:@INPUT" => [
            { label: "@INPUT", pos: 124, sections: input_sections, size: 136 }
          ],
          "label:@MAIN" => [
            { label: "@MAIN", pos: 260, sections: main_sections, size: 211 }
          ]
        }
        assert_equal(expected, actual)
      end
    end

    sub_test_case "#dump_parsed_config" do
      test "simple" do
        parsed_config = @agent.__send__(:parse_config, fixture_content("config/simple.conf"))
        config = @agent.__send__(:dump_parsed_config, parsed_config)
        assert_equal(fixture_content("config/simple.conf"), config)
      end

      test "simple label" do
        parsed_config = @agent.__send__(:parse_config, fixture_content("config/label.conf"))
        config = @agent.__send__(:dump_parsed_config, parsed_config)
        assert_equal(fixture_content("config/label.conf"), config)
      end

      test "multiple labels" do
        parsed_config = @agent.__send__(:parse_config, fixture_content("config/multi-label.conf"))
        config = @agent.__send__(:dump_parsed_config, parsed_config)
        assert_equal(fixture_content("config/multi-label.conf"), config)
      end
    end

    sub_test_case "#config_merge" do
      test "simple" do
        stub(@agent).config { fixture_content("config/simple.conf") }
        stub(@agent).backup_config
        content = <<-CONFIG
<match dummy3>
  @type stdout
</match>
        CONFIG
        mock(@agent).config_append(content)
        @agent.config_merge(content)
      end

      test "simple with label" do
        stub(@agent).config { fixture_content("config/simple.conf") }
        stub(@agent).backup_config
        content = <<-CONFIG
<label @INPUT>
  <match dummy3>
    @type stdout
  </match>
</label>
        CONFIG
        mock(@agent).config_append(content)
        @agent.config_merge(content)
      end

      test "append to label" do
        stub(@agent).config { fixture_content("config/label.conf") }
        stub(@agent).config_file { "tmp/fluent.conf" }
        stub(@agent).backup_config
        content = <<-CONFIG
<label @INPUT>
  <match dummy3>
    @type stdout
  </match>
</label>
        CONFIG
        mock(@agent).config_write(<<-CONFIG)
<source>
  @type dummy
  tag dummy
  @label @INPUT
</source>

<label @INPUT>
  <filter dummy>
    @type stdout
  </filter>

  <match dummy>
    @type stdout
  </match>

  <match dummy3>
    @type stdout
  </match>
</label>
        CONFIG
        @agent.config_merge(content)
      end
    end
  end
end
