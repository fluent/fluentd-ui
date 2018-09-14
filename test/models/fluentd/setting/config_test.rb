require "test_helper"

class FluentdConfigTest < ActiveSupport::TestCase
  def create_config(fixture_name)
    ::Fluentd::Setting::Config.new(fixture_path(fixture_name))
  end

  sub_test_case "#delete_element" do
    test "delete a source" do
      config = create_config("config/simple.conf")
      element = config.elements(name: "source").first
      config.delete_element("source", nil, element)
      assert_equal(config.formatted.strip, <<CONFIG.chomp)
<filter dummy>
  @type stdout
</filter>

<match dummy>
  @type stdout
</match>
CONFIG
    end

    test "delete a filter" do
      config = create_config("config/simple.conf")
      element = config.elements(name: "filter").first
      config.delete_element("filter", nil, element)
      assert_equal(config.formatted.strip, <<CONFIG.chomp)
<source>
  @type dummy
  tag dummy
</source>

<match dummy>
  @type stdout
</match>
CONFIG
    end

    test "delete a match" do
      config = create_config("config/simple.conf")
      element = config.elements(name: "match").first
      config.delete_element("match", nil, element)
      assert_equal(config.formatted.strip, <<CONFIG.chomp)
<source>
  @type dummy
  tag dummy
</source>

<filter dummy>
  @type stdout
</filter>
CONFIG
    end

    test "delete all elements under the label" do
      config = create_config("config/multi-label.conf")
      input = config.elements(name: "label", arg: "@INPUT").first
      input.elements.each do |element|
        config.delete_element("label", "@INPUT", element)
      end
      assert_equal(config.formatted.strip, <<CONFIG.chomp)
<source>
  @type dummy
  tag dummy1
  @label @INPUT
</source>

<source>
  @type dummy
  tag dummy2
  @label @INPUT
</source>

<label @MAIN>
  <filter dummy1>
    @type stdout
  </filter>
  <filter dummy2>
    @type stdout
  </filter>
  <match dummy1>
    @type stdout
  </match>
  <match dummy2>
    @type stdout
  </match>
</label>
CONFIG
    end

    test "cannot delete specified element" do
      config = create_config("config/simple.conf")
      element = ::Fluent::Config::Element.new("source", nil, { :@type => "dummy", :tag => "dummy" }, [])
      assert_nil(config.delete_element("source", nil, element))
    end
  end
end
