require "test_helper"

class PluginTest < ActiveSupport::TestCase
  setup do
    @plugin = FactoryBot.build(:plugin)
  end

  sub_test_case ".installed" do
    setup do
      gem_list = <<-GEM_LIST.strip_heredoc
        dummy (3.3.3)
        fluent-plugin-foo (0.1.2)
        more_dummy (0.0.1)
      GEM_LIST
      stub(FluentGem).gem { "gem" }
      stub(FluentGem).__double_definition_create__.call(:`, "gem list 2>&1") { gem_list }
      @target = Plugin.new(gem_name: "fluent-plugin-foo", version: "0.1.2")
    end

    test "detect foo plugin" do
      assert_equal(@target.inspect, Plugin.installed.first.inspect)
    end

    test "detected foo plugin is marked as installed" do
      assert do
        @target.installed?
      end
    end

    test "detected foo plugin version to be installed_version" do
      assert_equal(@target.version, @target.installed_version)
    end
  end

  sub_test_case "#valid?" do
    data("nil is invalid" => [nil, false],
         "something filled is valid" => ["foobar", true])
    test "gem_name" do |(name, is_valid)|
      @plugin.gem_name = name
      assert_equal(is_valid, @plugin.valid?)
    end

    data("nil is invalid" => [nil, false],
         "something filled is valid" => ["0.0.1", true])
    test "version" do |(version, is_valid)|
      @plugin.version = version
      assert_equal(is_valid, @plugin.valid?)
    end
  end

  sub_test_case "#install!" do
    def install_plugin(is_valid, is_installed)
      stub(@plugin).valid? { is_valid }
      stub(@plugin).installed? { is_installed }
      @plugin.install!
    end


    data("installed" => [true, 0],
         "not installed" => [false, 1])
    test "valid" do |(is_installed, n)|
      mock(FluentGem).install(anything, "--no-ri", "--no-rdoc", "-v", anything).times(n) {}
      install_plugin(true, is_installed)
    end

    data("installed" => [true, :install],
         "not installed" => [false, :installed])
    test "invalid" do |(is_installed, method)|
      mock(FluentGem).__send__(method).times(0)
      install_plugin(false, is_installed)
    end

    test "system command error" do
      stub(FluentGem).gem { "gem" }
      mock(FluentGem).system("gem", "install", "fluent-plugin-dummy", "--no-ri", "--no-rdoc", "-v", "1.2.3").at_least(1) { false }
      assert_raise(FluentGem::GemError.new("failed command: `gem install fluent-plugin-dummy --no-ri --no-rdoc -v 1.2.3`")) do
        @plugin.install!
      end
    end
  end

  data("installed" => [true, 1],
       "uninstalled" => [false, 0])
  test "#uninstall!" do |(is_installed, n)|
    installed_plugin = FactoryBot.build(:plugin, gem_name: "fluent-plugin-foobar")
    mock(installed_plugin).installed? { is_installed }
    mock(installed_plugin).gem_uninstall.times(n) {}
    installed_plugin.uninstall!
  end

  test "#upgrade!" do
    installed_plugin = FactoryBot.build(:plugin, gem_name: "fluent-plugin-foobar", version: "1.0.0")
    stub(installed_plugin).installed? { true }
    stub(FluentGem).gem { "gem" }
    stub(FluentGem).run("gem", "install", "fluent-plugin-foobar", "--no-ri", "--no-rdoc", "-v", "1.2.0") { true }
    mock(installed_plugin).uninstall! {}
    mock(FluentGem).install("fluent-plugin-foobar", "--no-ri", "--no-rdoc", "-v", "1.2.0") {}
    installed_plugin.upgrade!("1.2.0")
  end

  test "#to_param" do
    assert do
      @plugin.to_param == @plugin.gem_name
    end
  end

  sub_test_case "Gem version" do
    setup do
      @plugin = FactoryBot.build(:plugin, version: "1.0.0")
      @versions = %w(1.0.1 0.99.1 1.0.0 0.99.0 0.1.0 0.0.3 0.0.2 0.0.1)
      @authors = %w(foo bar)
      json_response = @versions.map do |version|
        {
          number: version,
          summary: "summary of #{version}",
          authors: @authors
        }
      end.to_json
      stub_request(:get, @plugin.gem_json_url).to_return(body: json_response)
    end

    test "latest version is 1.0.0" do
      assert_equal("1.0.1", @plugin.latest_version)
    end

    test "1.0.0 is not lates" do
      assert do
        !@plugin.latest_version?
      end
    end

    test "released_versions is sorted" do
      assert_equal(@versions.sort_by{|ver| Gem::Version.new(ver) }.reverse, @plugin.released_versions)
    end

    test "authors" do
      assert_equal(@authors, @plugin.authors)
    end

    test "summary" do
      assert_equal("summary of #{@plugin.version}", @plugin.summary)
    end
  end
end
