require "test_helper"

class FluentdUITest < ActiveSupport::TestCase
  sub_test_case ".update_available?" do
    setup do
      @current_version = FluentdUI::VERSION
    end

    test "unavailable" do
      FluentdUI.latest_version = @current_version
      assert do
        !FluentdUI.update_available?
      end
    end

    test "available" do
      FluentdUI.latest_version = @current_version.succ
      assert do
        FluentdUI.update_available?
      end
    end
  end

  sub_test_case ".fluentd_version" do
    test "not ready" do
      stub(Fluentd).instance { nil }
      assert_nil(FluentdUI.fluentd_version)
    end

    test "ready" do
      target = FactoryBot.build(:fluentd)
      stub(Fluentd).instance{ target }
      assert_equal(target.agent.version, FluentdUI.fluentd_version)
    end
  end
end
