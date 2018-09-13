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
            { pos: 84, content: match_section_content }
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
            { pos: 75, content: filter_section_content}
          ],
          "match" => [
            { pos: 121, content: match_section_content}
          ]
        }
        expected = {
          "source" => [
            { pos: 0, content: source_section_content }
          ],
          "label:@INPUT" => [
            { pos: 60, sections: sections }
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
            { pos: 140, content: filter_section_content }
          ],
          "match" => [
            { pos: 187, content: match_section_content }
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
            { pos: 274, content: filter_secion_content1 },
            { pos: 321, content: filter_secion_content2 }
          ],
          "match" => [
            { pos: 368, content: match_secion_content1 },
            { pos: 413, content: match_secion_content2 }
          ]
        }
        expected = {
          "source" => [
            { pos: 0, content: source_section_content1 },
            { pos: 61, content: source_section_content2 },
          ],
          "label:@INPUT" => [
            { pos: 124, sections: input_sections }
          ],
          "label:@MAIN" => [
            { pos: 259, sections: main_sections }
          ]
        }
        assert_equal(expected, actual)
      end
    end
  end
end
