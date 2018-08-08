require "test_helper"

class FluentGemTest < ActiveSupport::TestCase

  data("no arguments" => [],
       "1 argument" => ["plugin-foo"],
       "2 arguments" => ["plugin-foo", "--no-document"])
  test "install" do |args|
    if args.empty?
      mock(FluentGem).run("install")
      FluentGem.install
    else
      mock(FluentGem).run("install", *args)
      FluentGem.install(*args)
    end
  end

  data("no arguments" => [],
       "1 argument" => ["plugin-foo"],
       "2 arguments" => ["plugin-foo", "--no-document"])
  test "uninstall" do |args|
    if args.empty?
      mock(FluentGem).run("uninstall")
      FluentGem.uninstall
    else
      mock(FluentGem).run("uninstall", *args)
      FluentGem.uninstall(*args)
    end
  end

  data("no list" => "",
       "some lines" => <<-GEM_LIST.strip_heredoc)
          dummy (3.3.3)
          fluent-plugin-foo (0.1.2)
          more_dummy (0.0.1)
       GEM_LIST
  test "list" do |gem_list|
    stub(FluentGem).gem { "gem" }
    stub(FluentGem).__double_definition_create__.call(:`, "gem list 2>&1") { gem_list }
    assert_equal(gem_list.lines.to_a, FluentGem.list)
  end

  sub_test_case("run") do
    test "success" do
      stub(FluentGem).gem { "gem" }
      args = ["install", "foobar"]
      stub(FluentGem).system("gem", *args) { true }
      assert_true(FluentGem.run(*args))
    end

    test "failure" do
      stub(FluentGem).gem { "gem" }
      args = ["install", "foobar"]
      stub(FluentGem).system("gem", *args) { false }
      assert_raise(FluentGem::GemError) do
        FluentGem.run(*args)
      end
    end
  end

  sub_test_case "gem" do
    test "any instance not setup yet" do
      assert_equal("fluent-gem", FluentGem.gem)
    end

    test "fluentd setup" do
      stub(Fluentd).instance { Fluentd.new(id: nil, variant: "fluentd_gem", log_file: "dummy.log", pid_file: "dummy.pid", config_file: "dummy.conf") }
      assert_equal("fluent-gem", FluentGem.gem)
    end

    test "td-agent 3 setup" do
      stub(Fluentd).instance {  Fluentd.new(id: nil, variant: "td_agent", log_file: "dummy.log", pid_file: "dummy.pid", config_file: "dummy.conf") }
      assert_equal(FluentGem.detect_td_agent_gem, FluentGem.gem)
    end
  end
end
